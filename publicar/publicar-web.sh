#!/usr/bin/env bash
# Publica a versão do navegador em https://fsadesigners.com.br/mythera/
# Uso (na VPS, como root): bash publicar/publicar-web.sh /root/mythera-web
# A pasta recebida é a exportação "Web" do Godot feita no PC (index.html, .wasm, .pck, .js...).
set -euo pipefail
ORIGEM="${1:-/root/mythera-web}"
DESTINO="/var/www/fsa-designer/mythera"
AQUI="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$ORIGEM/index.html" ] || ! ls "$ORIGEM"/*.wasm >/dev/null 2>&1; then
  echo "Não achei index.html e .wasm em $ORIGEM. Exporte pelo Godot (Projeto > Exportar > Web) e envie a pasta." >&2
  exit 1
fi

mkdir -p "$DESTINO"
rsync -a --delete --exclude .htaccess "$ORIGEM"/ "$DESTINO"/
cp "$AQUI/.htaccess" "$DESTINO/.htaccess"
chown -R www-data:www-data "$DESTINO"
echo "Publicado em https://fsadesigners.com.br/mythera/"
