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

def _hitotsu(pr):
    if pr == b'\x40\x40':
        return '　'                      # 全角空白
    try:
        return pr.decode('euc_jp')
    except Exception:
        return GAIJI.get(pr.hex(), '〓')  # 〓（富士通の外字）

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
