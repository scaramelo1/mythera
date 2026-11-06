"""Cliente mínimo da API do PixelLab (https://api.pixellab.ai/v2).

A chave fica em /etc/mythera-pixellab.env (só a chave, ou PIXELLAB_TOKEN=chave). Nunca vai para o git.
Uso:
  python3 ferramentas/pixellab.py saldo
  python3 ferramentas/pixellab.py post /create-character-with-4-directions pedido.json
  python3 ferramentas/pixellab.py get /characters/<id>
  python3 ferramentas/pixellab.py esperar <job_id>
  python3 ferramentas/pixellab.py baixar <url> <arquivo>
"""
import json, sys, time, urllib.request, urllib.error

BASE = "https://api.pixellab.ai/v2"
ARQUIVO_CHAVE = "/etc/mythera-pixellab.env"


def chave():
    texto = open(ARQUIVO_CHAVE).read().strip()
    for linha in texto.splitlines():
        linha = linha.strip()
        if linha.startswith("PIXELLAB_TOKEN="):
            return linha.split("=", 1)[1].strip().strip("'\"")
    return texto.splitlines()[0].strip()


def pedir(metodo, caminho, corpo=None):
    dados = json.dumps(corpo).encode() if corpo is not None else None
    req = urllib.request.Request(BASE + caminho, data=dados, method=metodo, headers={
        "Authorization": "Bearer " + chave(), "Content-Type": "application/json", "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read() or b"{}")
    except urllib.error.HTTPError as e:
        print("ERRO", e.code, e.read().decode()[:800], file=sys.stderr)
        sys.exit(1)


def esperar(job_id, limite=900):
    inicio = time.time()
    while time.time() - inicio < limite:
        r = pedir("GET", f"/background-jobs/{job_id}")
        estado = r.get("status")
        if estado in ("completed", "failed", "cancelled", "error"):
            return r
        time.sleep(10)
    return {"status": "tempo esgotado"}


def baixar(url, destino):
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + chave()})
    with urllib.request.urlopen(req, timeout=120) as r, open(destino, "wb") as f:
        f.write(r.read())


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "saldo":
        print(json.dumps(pedir("GET", "/balance"), indent=1))
    elif cmd == "get":
        print(json.dumps(pedir("GET", sys.argv[2]), indent=1))
    elif cmd == "post":
        print(json.dumps(pedir("POST", sys.argv[2], json.load(open(sys.argv[3]))), indent=1))
    elif cmd == "esperar":
        print(json.dumps(esperar(sys.argv[2]), indent=1)[:3000])
    elif cmd == "baixar":
        baixar(sys.argv[2], sys.argv[3])
