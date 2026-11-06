"""Anima um personagem do PixelLab direção por direção (o plano de teste só aceita 1 por vez).
Uso: python3 ferramentas/pixellab_animar.py <character_id> <template> <pasta_saida> [direções...]
Salva <pasta_saida>/<template>/<direção>_<n>.png
"""
import base64, json, os, sys, time
sys.path.insert(0, os.path.dirname(__file__))
import pixellab as pl

cid, modelo, saida = sys.argv[1], sys.argv[2], sys.argv[3]
direcoes = sys.argv[4:] or ["south", "west", "east", "north"]
grupo = os.environ.get("GRUPO") or None
os.makedirs(os.path.join(saida, modelo), exist_ok=True)
for d in direcoes:
    corpo = {"character_id": cid, "mode": "template", "template_animation_id": modelo,
             "animation_name": modelo, "directions": [d]}
    if grupo:
        corpo["animation_group_id"] = grupo
    r = pl.pedir("POST", "/characters/animations", corpo)
    grupo = r.get("animation_group_id") or grupo
    job = r["background_job_ids"][0]
    res = pl.esperar(job)
    print(d, res.get("status"), res.get("usage"), flush=True)
    if res.get("status") != "completed":
        print(json.dumps(res)[:800])
        sys.exit(1)
    json.dump(res, open(os.path.join(saida, modelo, f"{d}.json"), "w"))
    lr = res.get("last_response", {})
    imagens = lr.get("images") or lr.get("frames") or []
    if isinstance(imagens, dict):
        imagens = imagens.get(d) or list(imagens.values())
    for i, im in enumerate(imagens):
        if isinstance(im, dict) and im.get("base64"):
            open(os.path.join(saida, modelo, f"{d}_{i}.png"), "wb").write(base64.b64decode(im["base64"]))
    print("  quadros salvos:", len(imagens), "| chaves:", list(lr.keys())[:10], flush=True)
print("grupo", grupo)
