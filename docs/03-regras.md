# Mythera: regras do protótipo (proposta)

O que vem do GDD está marcado assim. O resto é proposta para o dono aprovar; os números serão ajustados depois de jogar. Tudo isso já está no código em `scripts/regras/` e tem testes em `testes/`.

## Elementos (protótipo: fogo, água e natureza)

- Fogo vence natureza, natureza vence água, água vence fogo.
- Com vantagem: dano × 1,5. Com desvantagem: dano × 0,67. Golpe sem elemento: × 1.

## Dano (proposta)

dano = piso(ataque × poder do golpe ÷ (defesa + 50) × vantagem × variação), mínimo 1

- Golpe físico usa **ataque** contra **defesa**; golpe elemental usa **poder** contra **resistência**.
- Variação aleatória entre 0,9 e 1,0.
- Exemplo: ataque 20, golpe de poder 40, defesa 15 → 12 de dano; com vantagem → 18.

## Atributos

- GDD: A(L) = A0 + G × (L − 1).
- Proposta: cada criatura nasce com um bônus próprio de 0 a 10% em cada atributo, para duas criaturas da mesma espécie serem diferentes: A(L) = piso((A0 + G × (L − 1)) × (1 + bônus)).
- Atributos: vida, ataque, defesa, poder (elemental), resistência (elemental) e velocidade.
- Valores de cada espécie em `dados/especies.json`.

## Experiência

- GDD: para passar do nível L para L + 1: 50 × L^1,5. Nível máximo 60.
- Proposta: vencer uma criatura dá 10 + 6 × nível dela.
- Ao subir de nível, a vida máxima aumenta e o aumento entra na vida atual.

## Captura

- GDD: P = limite(B + 0,40 × (1 − H) + N + S + V, entre 5% e 95%).
- Núcleos (N): simples +0%, bom +10%, ótimo +20%.
- Condições (S): dormindo, paralisada ou congelada dão +10%; não se somam.
- Captura de perto no começo: até 4 m.
- Não dá para tentar sem núcleo, sem alvo, longe demais ou em criatura que já tem dono.
- Equipe cheia (6) não impede: a criatura vai para a reserva.
- A tentativa gasta o núcleo mesmo quando falha (proposta).

## Evolução

- GDD: estágios 1–17, 18–39 e 40–60.
- Flarin evolui para Flarvex (nome provisório) no nível 18.
- A evolução troca a espécie e mantém ID, nível, experiência, vínculo e bônus. A vida continua na mesma proporção.

## Salvamento

- Arquivo JSON com número de versão, gravado primeiro num temporário (não corrompe se o jogo fechar no meio).
- Arquivo estragado ou ausente vira "jogo novo".
