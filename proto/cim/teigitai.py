# -*- coding: utf-8 -*-
"""定義体（画面220本・帳票201本）を読んで、人が見える形に並べる。

   cim/teigitai.json は bin/gen_teigitai_all.py が現物から起こしたもの。
   ここでは「80桁×n行の枡目」に項目を置き直すだけで、形は足さない。
"""
import json, os, unicodedata

_MICHI = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'teigitai.json')
_ZEN = None

def zenbu():
    global _ZEN
    if _ZEN is None:
        with open(_MICHI, encoding='utf-8') as f:
            _ZEN = json.load(f)
    return _ZEN

def hitotsu(na):
    return zenbu().get(na)

def ichiran(kind=None):
    z = zenbu()
    return sorted((t for t in z.values() if kind is None or t['kind'] == kind),
                  key=lambda t: t['na'])

def haba(s):
    """画面の桁は**バイト**。全角は2桁ぶん。"""
    n = 0
    for c in s or '':
        n += 2 if unicodedata.east_asian_width(c) in 'FWA' else 1
    return n


def narabe(t, atai=None):
    """定義体1本を「行ごとの枡目」に並べ直す。

       戻り値 … [{'gyo': 行, 'cell': [ {'keta','naga','midashi'|'nm','atai'} ... ]}]
       atai … {項目名: 出す値} を渡すと、入力項目にその値を入れる。
    """
    atai = atai or {}
    gyo = {}
    for k in t['ko']:
        gyo.setdefault(k['gyo'], []).append(k)
    out = []
    for g in sorted(gyo):
        cell = []
        for k in sorted(gyo[g], key=lambda x: x['keta']):
            if k['midashi'] is not None:
                cell.append({'keta': k['keta'], 'naga': k['naga'],
                             'midashi': k['midashi'], 'nm': k['nm']})
            else:
                cell.append({'keta': k['keta'], 'naga': k['naga'],
                             'nm': k['nm'], 'atai': atai.get(k['nm'], ''),
                             'iryoku': True})
        out.append({'gyo': g, 'cell': cell})
    return out


def moji_gamen(t, atai=None):
    """定義体1本を、80桁の文字の絵にする（文字だけで形が見られる）。"""
    atai = atai or {}
    hyo = {}
    for k in t['ko']:
        s = k['midashi'] if k['midashi'] is not None else str(atai.get(k['nm'], ''))
        if k['midashi'] is None and not s:
            s = '_' * k['naga']                 # 入力・出力の枠
        hyo.setdefault(k['gyo'], []).append((k['keta'], s, k['naga']))
    gyo = []
    for g in range(0, (max(hyo) + 1) if hyo else 0):
        b = bytearray(b' ' * 200)
        for keta, s, naga in sorted(hyo.get(g, [])):
            d = s.encode('cp932', 'replace')[:max(naga, 1)]
            i = max(0, keta - 1)
            b[i:i+len(d)] = d
        gyo.append(bytes(b).rstrip().decode('cp932', 'replace'))
    return gyo
