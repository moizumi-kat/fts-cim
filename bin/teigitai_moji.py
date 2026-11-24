# -*- coding: utf-8 -*-
"""定義体の「見出しの文字」を読む。

   ■ どう入っているか（2026-11-20 実測・画面220本＋帳票201本）
     属性レコード（「次の表」18バイト）の **+2 が文字の種類**。
       0x42 … 1バイト文字だけ（EBCDIC）。画面名・記号など
       0x43 … 2バイト文字だけ（JEF＝ほぼ EUC-JP と同じ並び）。0x4040 は全角空白
       0x44 … 混ざり。**0x28 から 0x29 までが2バイト文字**（JEF のシフト符号。
              0x28=シフトアウト／0x29=シフトイン）。外は EBCDIC 1文字
     2バイトの字は 40,819 字あり、**99.4% が EUC-JP として読めた**。
     読めない 39 種・247 字は富士通の外字（JEF 拡張）。〓 で出し、
     見当のついたものだけ下の表で置き換える（増やすときは根拠を書くこと）。
"""
# 外字（JEF 拡張）のうち、前後の言葉から中身が分かったもの
GAIJI = {
    '76fa': 'No.',     # 「見積No.」「物件No.」。ハードコピーの見出しと一致（102か所）
}

# **データを読むとき用**の外字の置き換え（2026-11-24 実測）。
#   見出し（画面・帳票の文字）は読みやすさを採って 'No.' と3文字に開くが、
#   **データでは桁が変わってしまう**（JEF 2バイト → cp932 3バイト）。
#   固定長の項目で後ろの全角文字が半分に切れ、鑑の件名・特記事項で
#   756件の食い違いになった。長さの変わらない1文字（№ U+2116＝cp932 2バイト）
#   に置き換える。
GAIJI_DATA = {
    '76fa': '\u2116',   # №（見積№・物件№）
}


def nibyte_data(raw):
    """データの JEF 2バイト文字を読む。**桁が変わらない**ようにする。"""
    out = []
    for i in range(0, len(raw) - 1, 2):
        pr = raw[i:i+2]
        if pr == b'\x40\x40':
            out.append('　')
            continue
        try:
            c = pr.decode('euc_jp')
        except Exception:
            out.append(GAIJI_DATA.get(pr.hex(), '〓'))
            continue
        out.append(CP932_NI.get(c, c))
    if len(raw) % 2:
        out.append(_ebcdic(raw[-1:]))
    return ''.join(out)

def moji(raw, shurui):
    """raw（定義体の生バイト）を、文字の種類 shurui（+2 の値）に従って読む。"""
    if shurui == 0x42:
        return _ebcdic(raw)
    if shurui == 0x43:
        return _nibyte(raw)
    return _mazari(raw)

def _ebcdic(raw):
    try:
        return raw.decode('cp500')
    except Exception:
        return raw.decode('cp500', 'replace')

# EUC-JP と cp932 で、**同じ字なのに Unicode の割り当てが違う**もの（2026-11-24 実測）。
#   JIS の字は1つなのに、Unicode へ写すときに2つの流儀がある（有名な「波ダッシュ問題」）。
#   現行システムのデータ（SQL Server 経由）は **cp932 の流儀**で入っているので、
#   そちらへ揃える。揃えないと、既存データと突き合わせたとき食い違う
#   （実データで 特記事項３ の全角ダッシュが70件ちがった）。
CP932_NI = {
    '\u2212': '\uff0d',   # − → －（全角ハイフンマイナス。JIS 1-61）
    '\u301c': '\uff5e',   # 〜 → ～（波ダッシュ。JIS 1-33）
    '\u2016': '\u2225',   # ‖ → ∥（双柱。JIS 1-34）
    '\u00a2': '\uffe0',   # ¢ → ￠（JIS 1-81）
    '\u00a3': '\uffe1',   # £ → ￡（JIS 1-82）
    '\u00ac': '\uffe2',   # ¬ → ￢（JIS 2-44）
}


def _hitotsu(pr):
    if pr == b'\x40\x40':
        return '　'                      # 全角空白
    try:
        c = pr.decode('euc_jp')
    except Exception:
        return GAIJI.get(pr.hex(), '〓')  # 〓（富士通の外字）
    return CP932_NI.get(c, c)

def _nibyte(raw):
    out = []
    for i in range(0, len(raw) - 1, 2):
        out.append(_hitotsu(raw[i:i+2]))
    if len(raw) % 2:
        out.append(_ebcdic(raw[-1:]))
    return ''.join(out)

SO, SI = 0x28, 0x29        # シフトアウト／シフトイン（2バイト文字のはじめと終わり）

def _mazari(raw):
    out = []; i = 0; n = len(raw); nibyte = False
    while i < n:
        c = raw[i]
        if not nibyte and c == SO:
            nibyte = True; i += 1; continue
        if nibyte and c == SI:
            nibyte = False; i += 1; continue
        if nibyte and i + 1 < n:
            out.append(_hitotsu(raw[i:i+2])); i += 2
        else:
            out.append(_ebcdic(raw[i:i+1])); i += 1
    return ''.join(out)
