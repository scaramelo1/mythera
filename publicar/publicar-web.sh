#!/usr/bin/env bash
# Publica a versão do navegador em https://fsadesigners.com.br/mythera/
# Uso (na VPS, como root): bash publicar/montar-web.sh && bash publicar/publicar-web.sh
# Sem argumento, publica exportar/web (gerada por montar-web.sh). Também aceita a pasta exportada pelo editor no PC.
set -euo pipefail
ORIGEM="${1:-$(cd "$(dirname "$0")/.." && pwd)/exportar/web}"
DESTINO="/var/www/fsa-designer/mythera"
AQUI="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$ORIGEM/index.html" ] || ! ls "$ORIGEM"/*.wasm >/dev/null 2>&1; then
  echo "Não achei index.html e .wasm em $ORIGEM. Rode antes: bash publicar/montar-web.sh" >&2
  exit 1
fi

mkdir -p "$DESTINO"
rsync -a --delete --exclude .htaccess "$ORIGEM"/ "$DESTINO"/
cp "$AQUI/.htaccess" "$DESTINO/.htaccess"
chown -R www-data:www-data "$DESTINO"
echo "Publicado em https://fsadesigners.com.br/mythera/"
