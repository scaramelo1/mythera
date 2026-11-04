# Mythera — O Despertar dos Guardiões

RPG de ação em mundo aberto, 3D cartoon: capturar criaturas, evoluir criaturas e herói. Godot 4.7.2, renderizador Compatibility (navegador primeiro, depois Android e iPhone).

- `docs/00-passos.md`: lista de tudo o que vamos fazer (✅ feito, 🔶 em andamento, ⬜ falta).
- `docs/01-conceito.md`, `docs/02-analise-gdd.md`, `docs/03-regras.md`; GDD original em `docs/referencia/`.
- `cenas/`: mapa de testes e herói.
- `scripts/heroi.gd`: andar, pular, esquivar e câmera. `scripts/entradas.gd`: teclas e controle. `scripts/ui/controles_toque.gd`: toque na tela.
- `scripts/regras/`: regras puras (elementos, dano, captura, experiência, criatura, coleção, salvamento).
- `dados/especies.json`: Flarin, Flarvex, Aquori e Mosshell.
- `testes/`: testes que rodam sem abrir o jogo.
- `publicar/`: script para publicar a versão do navegador no site.

## Rodar

Abra a pasta no Godot 4.7.2 (Importar → `project.godot`) e aperte F5.

```bash
godot --headless --path . -s testes/rodar.gd        # regras
godot --headless --path . -s testes/teste_cena.gd   # herói no mapa
```

Na VPS (1 GB de RAM) só os testes acima, com limite de memória; o editor e a exportação rodam no PC.

## Publicar no navegador

1. No PC: Projeto → Exportar → Web → Exportar projeto (sai em `exportar/web/`). Na primeira vez, o Godot pede para baixar os "modelos de exportação".
2. Enviar a pasta para a VPS: `scp -r exportar/web root@177.153.68.212:/root/mythera-web`
3. Na VPS: `bash publicar/publicar-web.sh /root/mythera-web` → https://fsadesigners.com.br/mythera/
