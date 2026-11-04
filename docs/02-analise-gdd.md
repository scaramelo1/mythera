# Análise do GDD Mythera 1.0

## O que está bom e fica como está

- Escopo do protótipo bem cortado: uma região, 3 elementos, uma criatura completa antes das outras e sem multiplayer.
- Separação entre espécie (dados fixos) e indivíduo (cada criatura capturada).
- Fórmula de captura conferida: o exemplo do documento dá 70% (0,20 + 0,40 × 0,75 + 0,10 + 0,10).
- Experiência de 50 × L^1,5: 50 do nível 1 para o 2, 1.581 no nível 10, 22.659 no nível 59; cerca de 546 mil no total até o 60. É uma curva razoável para começar.
- Salvar dados e recriar as criaturas ao carregar, sem guardar referências a objetos do mapa.
- Critérios claros para considerar o protótipo pronto (seção 15).

## Pontos a resolver

1. **As imagens não podem entrar no jogo.** A da capa tem a marca "aniimoverse.com" e a do Aquori tem assinatura de outro autor. Servem só como inspiração; a arte do jogo precisa ser nossa ou comprada com licença.
2. **O Voltiri está parecido demais com o Pikachu** (amarelo, bochechas vermelhas, raio, orelhas pontudas). Precisa de outra forma, outra cor ou outro animal de base. O Flarin, o Aquori e o Mosshell estão longe o bastante, mas também precisam do desenho próprio.
3. **O nome "Mythera" precisa de pesquisa** de marca e de lojas antes de virar definitivo.
4. **Blueprints não são texto.** Na Unreal, os Blueprints são arquivos binários: eu não consigo escrevê-los daqui da VPS, só explicar clique a clique. Para eu escrever o código, a lógica precisa ser em C++ (a Unreal aceita) ou o motor precisa ser outro.
5. **Unreal Engine 5 pede um PC forte:** 32 GB de RAM, placa de vídeo boa e uns 100 GB de disco. Com C++, também o Visual Studio 2022.
6. **Fórmula de atributo sem diferença entre indivíduos.** O GDD diz que duas criaturas da mesma espécie podem ser diferentes, mas A0 + G × (L − 1) dá o mesmo valor. Sugestão: cada criatura nasce com um bônus aleatório pequeno (de 0 a 10%) em cada atributo.
7. **Dano ainda sem fórmula** e sem tabela de vantagens entre elementos. Sugestão para o protótipo: dano = ataque × poder do golpe × vantagem ÷ (defesa + 50), com vantagem de 1,5 / 1 / 0,67 entre fogo → natureza → água → fogo.
8. **Equipe de 6, mas só uma criatura ativa no protótipo.** Está certo para começar; mais criaturas ativas ficam para depois.

## Caminhos para o motor

| | Unreal 5 com C++ | Unreal 5 só com Blueprints (como no GDD) | Godot 4 em 3D |
|---|---|---|---|
| Visual | O mais bonito | O mais bonito | Bom para 3D cartoon |
| Quem escreve | Eu escrevo o C++; você monta mapa, modelos e telas no editor | Você faz tudo no editor, eu explico passo a passo | Eu escrevo quase tudo (scripts e cenas são texto) |
| PC necessário | Forte (32 GB) e Visual Studio | Forte (32 GB) | Comum (8 a 16 GB) |
| Celular depois | Difícil | Difícil | Mais fácil |
| Recomendação | Se o seu PC aguenta e você quer o visual máximo | Não recomendo: eu ajudo pouco | **Recomendado** para trabalharmos juntos do jeito dos outros projetos |
