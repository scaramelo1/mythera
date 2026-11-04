# Mythera: passos

Lista de tudo o que vamos fazer. Cada passo concluído recebe ✅ e a lista atualizada é mostrada ao dono.

Legenda: ✅ feito | 🔶 em andamento | ⬜ falta

Base: o GDD do dono (`referencia/mythera-gdd-1.0.pdf`), adaptado para **2D visto de cima**. Tudo original: nome, criaturas, arte, músicas e mapa. Sem pagar para vencer e sem caixa surpresa. Na VPS: código, testes e a montagem da versão do navegador (sem o editor, que não cabe na memória).

## 0. Planejamento

- ✅ GDD recebido e estudado (`02-analise-gdd.md`) (2026-11-04)
- ✅ Motor: Godot 4.7.2 (2026-11-04)
- ✅ Jogo em 2D visto de cima (decisão do dono em 2026-11-04; o projeto 3D foi apagado)
- ✅ Plataformas: navegador primeiro, depois Android e iPhone, renderizador Compatibility (2026-11-04)
- ⬜ Pesquisar e confirmar o nome "Mythera"
- ⬜ Redesenhar o Voltiri (parecido demais com o Pikachu)
- 🔶 Regras do protótipo em `03-regras.md`: dano, bônus individual, experiência por vitória, núcleo gasto na falha (falta o dono aprovar)

## 1. Fundação 2D

- ✅ Projeto 2D: tela 1280 × 720, câmera com zoom 2, controles de teclado, controle e toque (2026-11-04)
- ✅ Vale Esmeralda de testes (80 × 60 tiles), sempre igual: clareira com fogueira, Pradaria, Floresta Antiga, Campo de Pedras e Lago Espelhado, ligados por caminhos (2026-11-04)
- ✅ Tiles, herói, criaturas, cristais e efeitos desenhados no código, provisórios até a arte chegar (2026-11-04)
- ✅ Testes: 27 das regras e do mapa (`testes/rodar.gd`) e 1 que joga sozinho (`testes/teste_jogo.gd`) (2026-11-04)
- ✅ Versão do navegador montada na VPS sem o editor (`publicar/montar-web.sh`), conferida rodando fora do projeto (2026-11-04)
- 🔶 Repositório `github.com/scaramelo1/mythera` (falta o dono criar no GitHub e dar o push)
- ⬜ Publicar em fsadesigners.com.br/mythera e o dono testar no PC e no celular

## 2. Primeiro modo de jogo: explorar e capturar

- 🔶 Herói: anda em 8 direções, ataca de perto (Espaço), esquiva (Shift) e lança o Núcleo (G) (2026-11-04) (falta o dono jogar)
- 🔶 Criaturas selvagens andando livres no mapa, com temperamento: Aquori foge, Mosshell revida, Flarin ataca quem chega perto (2026-11-04)
- 🔶 Criaturas nascem por área, com nível de acordo com a distância do início, e voltam a aparecer (2026-11-04)
- 🔶 Captura com o Núcleo de Vínculo e a fórmula do GDD; a chance aparece em cima da criatura mais perto (2026-11-04)
- 🔶 Primeira criatura capturada vira companheira: segue o herói, luta junto e obedece ao comando (F) (2026-11-04)
- 🔶 Experiência para herói e companheira; Flarin evolui para Flarvex no nível 18 (2026-11-04)
- 🔶 Fogueira cura todos e salva; desmaiar leva de volta à fogueira (2026-11-04)
- 🔶 Cristais de Essência pelo mapa dão Núcleos (voltam em 90 s) (2026-11-04)
- 🔶 Painel da equipe (Tab): ver as criaturas e trocar a ativa (2026-11-04)
- 🔶 Salvamento automático (a cada 30 s, ao capturar, ao subir de nível e na fogueira) (2026-11-04)
- ⬜ O dono jogar e aprovar a sensação do combate e da captura
- ⬜ Ajustar números (dano, vida, chance, experiência) depois de jogar

## 3. Próximos sistemas

- ⬜ Golpe especial do herói (Q) e segundo golpe das criaturas
- ⬜ Fabricação: madeira, pedra e cristais viram núcleos melhores e poções
- ⬜ Dia e noite mudando as criaturas que aparecem
- ⬜ Registro de criaturas (vistas e capturadas)
- ⬜ Trocar criaturas entre equipe e reserva
- ⬜ Minichefe da região
- ⬜ Condições (dormindo, paralisada) que ajudam na captura

## 4. Arte e som 2D

- ⬜ Escolher o estilo (pixel art ou desenho liso) e o tamanho dos tiles
- ⬜ Herói com animação em 4 direções (parado, andar, atacar, esquivar, lançar)
- ⬜ Flarin, Flarvex, Aquori e Mosshell com animação (parado, andar, atacar, levar dano, desmaiar)
- ⬜ Tiles do Vale Esmeralda (grama, capim, água, areia, árvores, pedras, caminho, fogueira)
- ⬜ Interface com arte própria
- ⬜ Músicas e sons

## 5. Mundo aberto

- ⬜ Mapa maior, carregando por partes
- ⬜ Vila pequena com personagens
- ⬜ Regiões do GDD: Terras de Ignis, Cordilheira Glacial, Floresta de Lumina, Deserto de Arkan e Ilhas Celestiais
- ⬜ Viagem rápida e montarias

## 6. Herói e progressão

- ⬜ Atributos vigor, força, essência e agilidade, com pontos a cada nível
- ⬜ Trilhas de talentos: guerreiro, vinculador, explorador, elementalista e artesão
- ⬜ Equipamentos que mudam a aparência

## 7. Missões e história

- ⬜ Missões guardadas como dados
- ⬜ Prólogo e Capítulos I a V

## 8. Conteúdo

- ⬜ 20 criaturas e depois os 10 elementos
- ⬜ Guardiões e chefes

## 9. Lançamento

- ⬜ Testes com amigos e ajuste de equilíbrio
- ⬜ Android: APK para testes e AAB para a Google Play (teste fechado com 12 pessoas por 14 dias)
- ⬜ iPhone: Apple Developer e build num Mac com Xcode
- ⬜ Página do jogo no site, classificação etária e política de privacidade
