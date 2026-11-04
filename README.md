# Mythera — O Despertar dos Guardiões

RPG de ação em 2D visto de cima: explorar, capturar criaturas, evoluir criaturas e herói. Godot 4.7.2, renderizador Compatibility (navegador primeiro, depois Android e iPhone).

- `docs/00-passos.md`: lista de tudo o que vamos fazer (✅ feito, 🔶 em andamento, ⬜ falta).
- `docs/01-conceito.md` (com os controles), `docs/02-analise-gdd.md`, `docs/03-regras.md`; GDD original em `docs/referencia/`.
- `cenas/vila.tscn` → `scripts/vila.gd`: tela inicial, a vila desenhada (`assets/mapas/vila.webp`), por enquanto só com o herói. Onde dá para andar: `dados/vila_mascara.json`, gerado por `python3 ferramentas/gerar_mascara_vila.py`.
- `cenas/jogo.tscn` → `scripts/jogo.gd`: o modo de explorar e capturar no Vale Esmeralda.
- `scripts/mundo/`: mapa, herói, criaturas no mapa, Núcleo, cristais e efeitos.
- `scripts/arte/`: tiles e desenhos provisórios feitos no código (sem arquivos de imagem).
- `scripts/ui/`: interface, painel da equipe e controles de toque.
- `scripts/regras/`: regras puras (elementos, dano, captura, experiência, criatura, herói, coleção, salvamento).
- `dados/especies.json`: Flarin, Flarvex, Aquori e Mosshell.
- `arte-original/`: arquivos originais enviados pelo dono (o Godot ignora a pasta).
- `testes/`: testes que rodam sem janela.
- `publicar/`: montar a versão do navegador e publicar no site.

## Rodar

No PC: abra a pasta no Godot 4.7.2 (Importar → `project.godot`) e aperte F5.

Testes (na VPS, sempre com limite de memória):

```bash
godot --headless --path . -s testes/rodar.gd       # regras e mapa
godot --headless --path . -s testes/teste_jogo.gd  # joga sozinho: andar, lutar, capturar, evoluir, salvar
godot --headless --path . -s testes/teste_vila.gd  # herói andando na vila sem atravessar nada
```

## Publicar no navegador (na VPS)

```bash
bash publicar/montar-web.sh      # gera exportar/web sem o editor
bash publicar/publicar-web.sh    # copia para https://fsadesigners.com.br/mythera/ (como root)
```
