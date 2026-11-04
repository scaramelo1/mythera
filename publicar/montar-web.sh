#!/usr/bin/env bash
# Monta a versão do navegador sem o editor do Godot (cabe na memória da VPS).
# Uso: bash publicar/montar-web.sh   → gera exportar/web/
# Precisa de: /opt/godot/Godot_v4.7.2-stable_linux.x86_64 e /opt/godot/templates/web_nothreads_release.zip
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT=/opt/godot/Godot_v4.7.2-stable_linux.x86_64
MODELO=/opt/godot/templates/web_nothreads_release.zip
SAIDA=exportar/web
rm -rf "$SAIDA" && mkdir -p "$SAIDA"

GODOT_SILENCE_ROOT_WARNING=1 systemd-run --scope -q -p MemoryMax=200M -p MemorySwapMax=64M \
  "$GODOT" --headless --path . -s ferramentas/montar_pck.gd -- "$SAIDA/index.pck"

TMP=$(mktemp -d)
unzip -q "$MODELO" -d "$TMP"
cp "$TMP/godot.js" "$SAIDA/index.js"
cp "$TMP/godot.wasm" "$SAIDA/index.wasm"
cp "$TMP/godot.audio.worklet.js" "$SAIDA/index.audio.worklet.js"
cp "$TMP/godot.audio.position.worklet.js" "$SAIDA/index.audio.position.worklet.js"
python3 -I - "$TMP/godot.html" "$SAIDA" <<'PY'
import json, os, sys
html, saida = sys.argv[1], sys.argv[2]
cfg = {"args": [], "canvasResizePolicy": 2, "ensureCrossOriginIsolationHeaders": False,
       "executable": "index", "experimentalVK": False, "focusCanvas": True, "gdextensionLibs": [],
       "serviceWorker": "",
       "fileSizes": {f: os.path.getsize(os.path.join(saida, f)) for f in ("index.pck", "index.wasm")}}
s = open(html).read()
troca = {"$GODOT_URL": "index.js", "$GODOT_PROJECT_NAME": "Mythera", "$GODOT_HEAD_INCLUDE": "",
         "$GODOT_CONFIG": json.dumps(cfg), "$GODOT_THREADS_ENABLED": "false",
         "$GODOT_SPLASH_CLASSES": "show-image--false fullsize--true use-filter--true",
         "$GODOT_SPLASH_COLOR": "#14301c", "$GODOT_SPLASH": ""}
for k in sorted(troca, key=len, reverse=True):
    s = s.replace(k, troca[k])
open(os.path.join(saida, "index.html"), "w").write(s)
PY
rm -rf "$TMP"
ls -la "$SAIDA"
