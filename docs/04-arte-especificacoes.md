# Mythera: especificações das imagens

Valem para toda arte do jogo 2D visto de cima. A referência de escala é o mapa da vila (`assets/mapas/vila.webp`, 1536 × 1024), onde uma porta tem cerca de 40 px de altura.

## Regras gerais

- Estilo: pixel art, igual ao mapa da vila. Contorno escuro, sem borrão, sem desfoque de movimento.
- O jogo mostra as imagens ampliadas 2× sem suavizar (filtro "nearest"). Desenhe no tamanho real, nunca já ampliado.
- Mesma "grossura de pixel" em tudo: se o mapa usa blocos de 2 px, os personagens também.
- Fundo transparente em tudo que não é mapa.
- Luz vindo de cima e um pouco da esquerda, como no mapa.
- Nada copiado de outros jogos (formas, símbolos, personagens).

## Formatos

| Tipo | Formato |
|---|---|
| Mapas | WEBP (qualidade 90 ou sem perdas) ou PNG |
| Personagens, criaturas, itens, efeitos, interface | PNG com transparência |
| Ícone do app | PNG 1024 × 1024, sem transparência |

## Mapas

- Até 2048 × 2048 por imagem (limite seguro para celular e navegador). Áreas maiores: dividir em pedaços de 1024 × 1024 que se encaixam.
- Câmera: a tela de 1280 × 720 mostra 640 × 360 px do mapa de cada vez.
- Junto com cada mapa, se possível, mandar a **máscara**: uma imagem do mesmo tamanho, branco = dá para andar, preto = bloqueado. Sem a máscara, eu monto a partir das cores e de marcações à mão.
- Opcional: **camada de cima** (PNG transparente do mesmo tamanho) só com copas de árvore e telhados, para o herói passar por trás deles.

## Herói

> Herói atual (PixelLab, 2026-11-06): quadros de 68 × 68, pés em (34, 57), personagem com ~49 px. O jogo usa esses valores (`scripts/mundo/heroi.gd`).

- Quadro de **48 × 64 px**; o personagem com cerca de **44 px** dos pés ao topo da cabeça.
- Pés no centro, a 4 px da borda de baixo, na mesma posição em todos os quadros.
- Direções: baixo, cima e lado (o outro lado é espelhado pelo jogo).

| Animação | Quadros | Velocidade |
|---|---|---|
| parado | 2 a 4 | 4 por segundo |
| andar | 4 a 6 | 8 por segundo |
| atacar | 4 | 12 por segundo |
| esquivar | 3 | 12 por segundo |
| lançar o Núcleo | 4 | 10 por segundo |
| levar dano | 1 a 2 | — |
| desmaiar | 3 | 6 por segundo |

## Criaturas

| Tamanho | Exemplos | Quadro | Corpo |
|---|---|---|---|
| Pequena | Flarin, Aquori, Voltiri | 48 × 48 | 28 a 34 px |
| Média | Mosshell, Flarvex | 64 × 64 | 40 a 48 px |
| Grande e chefes | guardiões | 96 × 96 ou 128 × 128 | — |

- Direções no começo: só de lado (o jogo espelha). Depois, baixo e cima.
- Animações: parado (2 a 4), andar (4), atacar (4), levar dano (1 a 2), desmaiar (3).
- Retrato para menus: 128 × 128, sem fundo.

## Folhas de animação (sprite sheets)

- Uma folha por personagem: cada **linha** é uma animação, cada **coluna** é um quadro, todos os quadros do mesmo tamanho, sem espaço entre eles.
- Ordem das linhas do herói: parado-baixo, parado-cima, parado-lado, andar-baixo, andar-cima, andar-lado, atacar-baixo, atacar-cima, atacar-lado, esquivar, lançar, dano, desmaiar.
- Nome do arquivo: `heroi.png`, `flarin.png`, `flarvex.png`… (minúsculas, sem acento).

## Itens, efeitos e interface

- Ícones de itens: 32 × 32 (mostrados a 64 × 64).
- Efeitos de golpe: quadros de 64 × 64, 4 a 6 quadros, um por elemento.
- Núcleo de Vínculo: 16 × 16 (voando) e 32 × 32 (ícone).
- Botões e painéis: desenhados em 9 partes (cantos fixos, meio que estica), pixel art no mesmo estilo.

## Ícones do app

- Base: 1024 × 1024, sem transparência (exigência da Apple).
- Android (o Godot gera a partir de): 192 × 192 (principal) e 432 × 432 (frente e fundo do ícone adaptativo).
- Navegador: 192 × 192 e 512 × 512.
