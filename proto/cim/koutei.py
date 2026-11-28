# -*- coding: utf-8 -*-
"""村上様確定の405工程（2026-10-06 修正版）。左メニューと、まだ作っていない工程の中身表示に使う。"""
import json, os

PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'data', 'koutei405.json')

# このプロトタイプで「実物として動く」工程 → 行き先のURL
IMPLEMENTED = {
 '営業日報照会'                   : '/nippou',
 '営業日報（Ａ）照会'             : '/nippou?a=1',
 '営業日報マスタ（目標）メンテナス': '/mokuhyo',
}

_cache = {}

def all():
    if 'p' not in _cache:
        p = json.load(open(PATH, encoding='utf-8'))
        p.sort(key=lambda x: (x['o1'], x['o2']))
        from .master import MASTER as _M          # ＣＡＳＥＴ仕様書から起こしたマスタ管理
        for x in p:
            x['url'] = IMPLEMENTED.get(x['nm'], '')
            if not x['url'] and x['no'] in _M:
                x['url'] = '/master/%d' % x['no']
        _cache['p'] = p
    return _cache['p']

def tree():
    """大分類＞中分類＞工程 の入れ子にして返す。"""
    out, dai, chu = [], None, None
    for p in all():
        if dai is None or dai['nm'] != p['dai']:
            dai = {'nm': p['dai'], 'chu': []}; out.append(dai); chu = None
        if chu is None or chu['nm'] != p['chu']:
            chu = {'nm': p['chu'], 'rows': []}; dai['chu'].append(chu)
        chu['rows'].append(p)
    return out

def get(no):
    for p in all():
        if p['no'] == no: return p
    return None

def stats():
    p = all()
    n = lambda k: sum(1 for x in p if x['kind'] == k)
    return {'total': len(p), 'jisso': sum(1 for x in p if x['url']),
            'kind': {k: n(k) for k in ('帳票','登録・更新','照会','処理','運用')},
            'noproto': sum(1 for x in p if x['noproto'])}
