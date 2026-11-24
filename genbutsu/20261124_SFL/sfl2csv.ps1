# ASP V29 バックアップファイル（.SFL）を CSV に変換する
# 形式は 256バイト境界のブロックで判別する
#   PF編成（物理ファイル）: CNTL ブロックあり。項目定義は SFL 内のテーブル（オフセット1280〜、1項目32バイト）から取得する
#   SF編成（順編成ファイル）: 0x300 に FLB ブロックあり。SFL 内に項目定義が無いため -Layout で外部定義を与える
#                             （-Layout 省略時はレコードを16進文字列のまま REC 列に出力する）
# レイアウト定義CSV（UTF-8、見出し行あり）の列: Name,Type,Len,Pos,Occurs,Step
#   Type:U/P/X/N  Len:1要素のバイト長  Pos:開始位置（1起点）  Occurs:繰返し回数（省略・0は繰返しなし）  Step:繰返し1回分のバイト長（省略時Len）
param([string]$InFile, [string]$OutFile, [string]$Layout)

$b   = [IO.File]::ReadAllBytes($InFile)
$ebc = [Text.Encoding]::GetEncoding(37)      # EBCDIC（項目名用）
$euc = [Text.Encoding]::GetEncoding(20932)   # JEF の JIS 範囲は EUC-JP と同一

function U16($o) { [int]$b[$o] * 256 + $b[$o + 1] }
function U32($o) { [int64](U16 $o) * 65536 + (U16 ($o + 2)) }

# ---- 形式の判別 ----
$cntl = -1
for ($o = 0; $o -lt $b.Length; $o += 256) {
    if ($b[$o] -eq 0xC3 -and $b[$o + 1] -eq 0xD5 -and $b[$o + 2] -eq 0xE3 -and $b[$o + 3] -eq 0xD3) { $cntl = $o; break }
}
if ($cntl -ge 0)                                 { $org = 'PF' }
elseif ($ebc.GetString($b, 0x300, 4) -eq 'FLB ') { $org = 'SF' }
else { Write-Error "CNTL / FLB ブロックが見つかりません（未対応形式）: $InFile"; exit 1 }

# ---- レコード位置の列挙 ----
$recPos = New-Object System.Collections.Generic.List[int]
$flags  = @{}
if ($org -eq 'PF') {
    # CNTL +0x10:レコード長 +0x20:有効件数 +0x24:総件数（削除済み含む）。データ部は CNTL の 0x800 バイト後から始まる
    # データ部は「フラグ1バイト（0x80:有効 0x00:削除済み）＋レコード」の連続で、フラグ0xFFで終端
    $recLen   = U16 ($cntl + 0x10)
    $cntValid = U32 ($cntl + 0x20)
    $cntTotal = U32 ($cntl + 0x24)
    $start    = $cntl + 0x800
    for ($p = $start; $p + $recLen -lt $b.Length -and $b[$p] -ne 0xFF; $p += $recLen + 1) {
        $flags[$b[$p]]++
        if ($b[$p] -eq 0x80) { $recPos.Add($p + 1) }   # 有効レコード以外（削除等）は出力しない
    }
    $eof = ($p + $recLen -lt $b.Length)
} else {
    # FLB +0x28:レコード長 +0x2A:1ブロックのレコード数 +0x2B:ブロック長（512バイト単位）
    # データ部は 0x500 からのブロックの連続。各ブロック先頭4バイトは「件数（2バイト）＋ブロック番号（2バイト）」で、
    # 件数 0x8000 のブロックで終端
    $recLen  = U16 0x328
    $perBlk  = $b[0x32A]
    $blkSize = $b[0x32B] * 512
    $start   = 0x500
    for ($p = $start; $p + 4 -le $b.Length; $p += $blkSize) {
        $c = U16 $p
        if ($c -eq 0x8000) { break }
        if ($c -gt $perBlk) { Write-Error ("ブロック件数が不正です（0x{0:X} で {1} 件）: $InFile" -f $p, $c); exit 1 }
        for ($k = 0; $k -lt $c; $k++) { $recPos.Add($p + 4 + $k * $recLen) }
    }
    $eof = ($p + 4 -le $b.Length)
}

# ---- 項目定義の取得 ----
$fields = @()
if ($org -eq 'PF') {
    # 0x0400 のレコード定義ブロック +0x0E に項目数がある
    for ($i = 0; $i -lt (U16 0x40E); $i++) {
        $o = 1280 + $i * 32
        $fields += [pscustomobject]@{
            Name   = $ebc.GetString($b, $o + 8, 8).Trim()
            Len    = U16 ($o + 16)                    # 1要素のバイト長
            Type   = [char]$ebc.GetString($b, $o + 18, 1)  # U:ゾーン10進 P:パック10進 X:英数 N:日本語(JEF)
            Digits = U16 ($o + 20)
            Pos    = U16 ($o + 24)                    # レコード内開始位置（1起点）
            Step   = U16 ($o + 26)                    # 繰返し1回分のバイト長
            Occurs = U16 ($o + 28)                    # 繰返し回数（0:繰返しなし）
        }
    }
} elseif ($Layout) {
    foreach ($r in (Import-Csv -LiteralPath $Layout -Encoding UTF8)) {
        $len = [int]$r.Len
        $fields += [pscustomobject]@{
            Name   = $r.Name.Trim().ToUpper()
            Len    = $len
            Type   = [char]$r.Type.Trim().ToUpper()
            Digits = 0
            Pos    = [int]$r.Pos
            Step   = $(if ($r.Step) { [int]$r.Step } else { $len })
            Occurs = $(if ($r.Occurs) { [int]$r.Occurs } else { 0 })
        }
    }
    $badType = $fields | Where-Object { 'U', 'P', 'X', 'N' -notcontains [string]$_.Type }
    if ($badType) { Write-Error "レイアウト定義の Type が不正です（U/P/X/N のみ）: $(($badType | ForEach-Object { $_.Name }) -join ', ')"; exit 1 }
}
if ($fields.Count) {
    # 各項目の最終要素の末尾位置（繰返し項目は最後の回の要素の末尾）
    $defLen = ($fields | ForEach-Object { $_.Pos - 1 + [Math]::Max(0, $_.Occurs - 1) * $_.Step + $_.Len } | Measure-Object -Maximum).Maximum
    if ($defLen -gt $recLen) { Write-Error "項目定義（$defLen バイト）がレコード長（$recLen バイト）を超えています: $InFile"; exit 1 }
}

# ---- 列の展開（繰返し項目は物理配置順に水平展開） ----
# 繰返し項目はグループ単位（同じ Step/Occurs で連続）に、1回目の全項目→2回目の全項目…の順で並べる
# 項目定義が無い（SF編成で -Layout 省略）ときは、レコード全体を16進文字列の REC 列とする
$colList = New-Object System.Collections.ArrayList
if (-not $fields.Count) {
    [void]$colList.Add([pscustomobject]@{ Col = 'REC'; F = [pscustomobject]@{ Type = 'H'; Len = $recLen }; Off = 0; Idx = 0 })
}
$groups = $fields | Where-Object { $_.Occurs -gt 0 } | Group-Object { "$($_.Step)/$($_.Occurs)" }
foreach ($f in $fields) {
    if ($f.Occurs -eq 0) { [void]$colList.Add([pscustomobject]@{ Col = $f.Name; F = $f; Off = $f.Pos - 1; Idx = 0 }); continue }
    $g = $groups | Where-Object { $_.Group[0].Pos -le $f.Pos -and $_.Group -contains $f }
    if ($g.Group[0] -ne $f) { continue }          # グループ先頭項目のときにまとめて展開
    for ($i = 1; $i -le $f.Occurs; $i++) {
        foreach ($m in $g.Group) {
            $name = $m.Name.PadRight(6, '_') + '_' + $i   # 仕様書4.2：6文字にパディング＋_連番
            [void]$colList.Add([pscustomobject]@{ Col = $name; F = $m; Off = $m.Pos - 1 + ($i - 1) * $m.Step; Idx = $i })
        }
    }
}

# ---- 値の変換 ----
$warn = New-Object System.Collections.ArrayList
$badNum = @{}   # 数値として不正な値（HIGH-VALUE 等）の項目別件数。該当値は空欄で出力する
function Dec($off, $f) {
    switch ($f.Type) {
        'U' {
            $s = ''; for ($k = 0; $k -lt $f.Len; $k++) { $s += [string]($b[$off + $k] -band 0x0F) }
            if ($s.Length -ne $f.Len) { $badNum[$f.Name]++; return '' }   # 下位4ビットが 0〜9 以外
            $neg = (($b[$off + $f.Len - 1] -band 0xF0) -eq 0xD0)
            $v = [decimal]::Parse($s); if ($neg) { $v = -$v }; return [string]$v
        }
        'P' {
            $s = ''; for ($k = 0; $k -lt $f.Len; $k++) { $s += $b[$off + $k].ToString('X2') }
            $sign = $s[-1]; $num = $s.Substring(0, $s.Length - 1)
            if ($num -notmatch '^[0-9]+$') { $badNum[$f.Name]++; return '' }
            $v = [decimal]::Parse($num)
            if ($sign -eq 'D' -or $sign -eq 'B') { $v = -$v }; return [string]$v
        }
        'X' { return '"' + $ebc.GetString($b, $off, $f.Len).TrimEnd().Replace('"', '""') + '"' }
        'N' {
            $sb = New-Object Text.StringBuilder
            for ($k = 0; $k -lt $f.Len; $k += 2) {
                $c1 = $b[$off + $k]; $c2 = $b[$off + $k + 1]
                if ($c1 -eq 0x40 -and $c2 -eq 0x40) { [void]$sb.Append([char]0x3000) }
                elseif ($c1 -ge 0xA1 -and $c2 -ge 0xA1 -and $c1 -le 0xFE -and $c2 -le 0xFE) { [void]$sb.Append($euc.GetString([byte[]]@($c1, $c2))) }
                else { [void]$sb.Append([char]0x3013); [void]$warn.Add(('{0:X2}{1:X2}' -f $c1, $c2)) }  # 変換不可は〓
            }
            return '"' + $sb.ToString().TrimEnd([char]0x3000, ' ').Replace('"', '""') + '"'
        }
        'H' { return [BitConverter]::ToString($b, $off, $f.Len).Replace('-', '') }
    }
}

# ---- 出力 ----
$out = New-Object System.Collections.Generic.List[string]
$out.Add(($colList | ForEach-Object { $_.Col }) -join ',')
$vals = New-Object string[] $colList.Count
foreach ($r in $recPos) {
    for ($j = 0; $j -lt $colList.Count; $j++) { $vals[$j] = Dec ($r + $colList[$j].Off) $colList[$j].F }
    $out.Add($vals -join ',')
}
[IO.File]::WriteAllLines($OutFile, $out, (New-Object Text.UTF8Encoding($true)))

"編成: $org / レコード長: $recLen / データ開始: 0x{0:X} / 列数: $($colList.Count)" -f $start
if ($org -eq 'PF') { "フラグ別件数: " + (($flags.GetEnumerator() | ForEach-Object { '{0:X2}={1}' -f $_.Key, $_.Value }) -join ' ') }
else { "ブロック長: $blkSize / 1ブロックのレコード数: $perBlk" + $(if (-not $fields.Count) { ' / 項目定義なし（REC列に16進で出力）' }) }
"出力件数: $($out.Count - 1)"
if (-not $eof) { Write-Warning "終端に到達する前にファイル末尾に達しました" }
if ($org -eq 'PF') {
    $walked = ($flags.Values | Measure-Object -Sum).Sum
    if ($walked -ne $cntTotal -or ($out.Count - 1) -ne $cntValid) { Write-Warning "CNTL の件数（総数 $cntTotal / 有効 $cntValid）と読み取り件数（総数 $walked / 有効 $($out.Count - 1)）が一致しません" }
}
if ($warn.Count) { "JEF変換不可コード: " + (($warn | Sort-Object -Unique) -join ' ') }
if ($badNum.Count) { Write-Warning ("数値として不正な値を空欄で出力しました: " + (($badNum.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key)=$($_.Value)件" }) -join ' ')) }
