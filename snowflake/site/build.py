import re, json, html
import markdown
from pymdownx.superfences import SuperFencesCodeExtension

from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
SRC=str(ROOT/"docs")+"/"
DOCS=[
 ("overview","00_overview.md","全体概要","ロードマップの全体像と物語の登場人物",None),
 ("s1","01_step1.md","アーキテクチャと基本操作","4月｜3層構造、ウェアハウス、テーブル、Time Travel","A"),
 ("s2","02_step2.md","セキュリティとアクセス制御","5月｜RBAC、認証、ネットワーク","A"),
 ("s3","03_step3.md","データエンジニアリングと自動化","6〜7月｜Snowpipe、Streams/Tasks、Dynamic Tables、dbt","B"),
 ("s4","04_step4.md","データガバナンスとコスト管理","8月｜タグ、マスキング、行アクセス、DMF、Budgets","B"),
 ("s5","05_step5.md","AI & ML（基礎）","9月｜AI Functions、ML関数、Cortex Search・Analyst","C"),
 ("s6","06_step6.md","AI アプリとエージェント","10〜11月｜RAG、Cortex Agents、MCP、ガードレール","C"),
 ("s7","07_step7.md","AI 可観測性と運用最適化","12月｜評価、監視、モデルレジストリ","C"),
]
def mermaid_fmt(source, language, class_name, options, md, **kw):
    return '<pre class="mmd">'+html.escape(source)+'</pre>'

# 【場面】【事例】で始まる引用ブロックをカードに変換する
MARK={"場面":"scene","事例":"case"}
def decorate_callouts(body):
    def bq(m):
        inner=m.group(1)
        h=re.match(r'\s*<p><strong>【(場面|事例)】(.*?)</strong>(.*?)</p>',inner,re.S)
        if not h: return m.group(0)
        kind=MARK[h.group(1)]
        head=f'<p class="callout-head"><span class="chip">{h.group(1)}</span>{h.group(2)}{h.group(3)}</p>'
        rest=inner[h.end():]
        # 「名前：「…」」の話者を強調する
        rest=re.sub(r'<p>([^<>：「」]{1,14})：(?=「)',r'<p class="line"><span class="who">\1</span>',rest)
        # 連続した引用ブロックは Markdown 上で1つに結合されるため、2つ目以降の見出しでカードを分ける
        rest=re.sub(r'<p><strong>【(場面|事例)】(.*?)</strong>(.*?)</p>',
            lambda n:f'</blockquote><blockquote class="callout {MARK[n.group(1)]}"><p class="callout-head"><span class="chip">{n.group(1)}</span>{n.group(2)}{n.group(3)}</p>',rest,flags=re.S)
        return f'<blockquote class="callout {kind}">{head}{rest}</blockquote>'
    return re.sub(r'<blockquote>(.*?)</blockquote>',bq,body,flags=re.S)

def case_rows(text):
    """「## N. 現場の事例」直後の一覧表から事例のメタ情報を取り出す"""
    m=re.search(r'^## \d+\. 現場の事例.*?$(.*?)(?=^### )',text,re.M|re.S)
    if not m: return []
    rows=[]
    for line in m.group(1).splitlines():
        cells=[c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells)>=4 and re.match(r'\d-[A-Z]',cells[0]):
            cid,title=cells[0].split(' ',1) if ' ' in cells[0] else (cells[0],'')
            rows.append({"id":cid,"title":title.strip(),"kind":cells[1],"sev":cells[2],"rel":cells[3]})
    return rows

pages=[]; cases=[]
for key,fn,title,sub,phase in DOCS:
    text=open(SRC+fn,encoding="utf-8").read()
    text=re.sub(r'^# .*\n','',text,count=1)  # drop H1; rendered in header
    md=markdown.Markdown(extensions=["tables","toc","pymdownx.tasklist","pymdownx.superfences","sane_lists"],
        extension_configs={"pymdownx.superfences":{"custom_fences":[{"name":"mermaid","class":"mermaid","format":mermaid_fmt}]},
                           "pymdownx.tasklist":{"custom_checkbox":False,"clickable_checkbox":True},
                           "toc":{"toc_depth":"2-3"}})
    body=md.convert(text)
    body=body.replace(' id="',' id="'+key+'-')
    body=re.sub(r'<table>',r'<div class="tbl"><table>',body); body=body.replace('</table>','</table></div>')
    body=decorate_callouts(body)
    body=re.sub(r'<h3 (id="[^"]+")>(事例 \d-[A-Z])',r'<h3 \1 class="case-h">\2',body)
    toc=[]
    for t in md.toc_tokens:
        toc.append({"id":key+"-"+t["id"],"name":html.unescape(t["name"]),"children":[{"id":key+"-"+c["id"],"name":html.unescape(c["name"])} for c in t["children"]]})
    # 事例の見出しアンカーを一覧表に対応づける
    anchors={}
    for t in toc:
        for c in t["children"]:
            mm=re.match(r'事例 (\d-[A-Z])',c["name"])
            if mm: anchors[mm.group(1)]=c["id"]
    for r in case_rows(text):
        r.update(step=key[1:],phase=phase,anchor=anchors.get(r["id"],key)); cases.append(r)
    pages.append({"key":key,"title":title,"sub":sub,"phase":phase,"body":body,"toc":toc})

# 事例索引ページ（種類の表記ゆれを6分類にまとめて絞り込みに使う）
KINDS=["障害対応","性能","コスト","セキュリティ・監査","依頼対応","設計判断"]
ALIAS={"セキュリティ":"セキュリティ・監査","問い合わせ":"依頼対応"}
def kind_key(s):
    for k in KINDS+list(ALIAS):
        if s.startswith(k): return ALIAS.get(k,k)
    return s
for c in cases: c["k"]=kind_key(c["kind"])
kinds=[k for k in KINDS if any(c["k"]==k for c in cases)]
filt='<div class="filters" role="group" aria-label="種類で絞り込む"><button class="btn on" data-k="">すべて</button>'+"".join(
    f'<button class="btn" data-k="{html.escape(k)}">{html.escape(k)}</button>' for k in kinds)+'</div>'
cards="".join(
    f'<a class="case-card" data-k="{html.escape(c["k"])}" href="#{c["anchor"]}" style="--pc:var(--phase-{c["phase"].lower()})">'
    f'<span class="case-id">{c["id"]}</span><span class="case-t">{html.escape(c["title"])}</span>'
    f'<span class="case-meta"><span class="chip">{html.escape(c["kind"])}</span><span>深刻度 {html.escape(c["sev"])}</span><span>{html.escape(c["rel"])}</span></span></a>'
    for c in cases)
pages.append({"key":"cases","title":"事例索引","sub":f"全ステップの現場の事例 {len(cases)} 件を種類別に","phase":None,
    "body":'<p>各ステップ第4章「現場の事例」の一覧です。演習を終えたステップの事例から読み進めてください。カードを押すと、そのステップの事例へ移動します。</p>'
           +filt+f'<div class="case-grid">{cards}</div>',"toc":[]})

tpl=open(Path(__file__).parent/"template.html",encoding="utf-8").read()
nav=[]
for p in pages:
    num = p["key"][1:] if p["key"].startswith("s") else ""
    nav.append({"key":p["key"],"num":num,"title":p["title"],"sub":p["sub"],"phase":p["phase"]})
def kicker(p):
    return {"overview":"ロードマップ","cases":"ケーススタディ"}.get(p["key"],"Step "+p["key"][1:])
sections="\n".join(f'<article class="page" id="page-{p["key"]}" data-key="{p["key"]}" hidden>'
   f'<header class="page-head"><p class="page-kicker">{kicker(p)}</p>'
   f'<h1>{html.escape(p["title"])}</h1><p class="page-sub">{html.escape(p["sub"])}</p></header>'
   f'<div class="prose">{p["body"]}</div>'
   f'<nav class="pager" data-key="{p["key"]}"></nav></article>' for p in pages)
out=tpl.replace("/*__NAV__*/",json.dumps(nav,ensure_ascii=False)).replace("/*__TOC__*/",json.dumps({p["key"]:p["toc"] for p in pages},ensure_ascii=False)).replace("<!--__PAGES__-->",sections)
(ROOT/"dist").mkdir(exist_ok=True)
open(ROOT/"dist"/"snowflake_training_guide.html","w",encoding="utf-8").write(out)
print(len(out), "bytes,", len(cases), "cases")
