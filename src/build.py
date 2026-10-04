import json,glob,os
here=os.path.dirname(os.path.abspath(__file__))
def load(col):
    out=[]
    for f in sorted(glob.glob(os.path.join(here,"data",col,"*.json"))):
        d=json.load(open(f,encoding="utf-8")); d=d.get("data",d) if "data" in d and "status" not in d and "title" not in d else d
        d["id"]=os.path.basename(f)[:-5]; out.append(d)
    return out
claims=load("claims"); claims.sort(key=lambda c:c.get("order",0))
for c in claims:                       # no personal ids in the public copy
    if c.get("verified_by"): c["verified_by"]="reviewer"
    for d in c.get("decisions",[]): d["reviewer"]="reviewer"
procs=load("procedures"); procs.sort(key=lambda p:p.get("order",0))
sources=load("sources")
for x in sources: x["text"]=""; x["captured_by"]=None
enc=lambda o: json.dumps(o,ensure_ascii=False).replace("<","\\u003c")
s=open(os.path.join(here,"page.src.html"),encoding="utf-8").read()
s=s.replace("/*SNAPSHOT*/",enc({"claims":claims,"procedures":procs,"sources":sources}))
s=s.replace("/*BUILD*/",enc(json.load(open(os.path.join(here,"build.json"),encoding="utf-8"))))
print("built:",len(claims),"claims,",len(procs),"procedures,",len(sources),"sources,",len(s),"bytes")

open(os.path.join(here,"..","index.html"),"w",encoding="utf-8").write(
 '<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">'
 '<meta name="description" content="Plain, source-linked steps for government paperwork in India.">'
 '<style>body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style></head><body>\n'+s+'\n</body></html>\n')
print("index.html written")
