# Feralis: conceito

> Nome provisório. O dono escolhe o nome definitivo no passo 1.

## A ideia em uma frase

Um explorador anda livre por um mundo aberto, encontra criaturas selvagens, enfraquece e captura cada uma, treina a equipe, faz as criaturas evoluírem e fica mais forte junto com elas.

## O que torna o jogo nosso

- **Herói que luta junto.** O herói não fica só olhando: ele tem vida, nível, habilidades e equipamento, e entra no combate ao lado das criaturas.
- **Vínculo.** Cada criatura tem um nível de vínculo com o herói, que sobe com batalhas, comida e cuidado. Algumas evoluções só acontecem com vínculo alto.
- **Criaturas que trabalham.** No acampamento, as criaturas capturadas coletam recursos, constroem e plantam, cada uma de acordo com o tipo (fogo cozinha, terra minera, planta cultiva).
- **Mundo vivo.** Dia e noite, clima e estações mudam quais criaturas aparecem e onde.

## Laço principal do jogo

1. Explorar o mundo aberto.
2. Encontrar uma criatura (ela aparece andando no mapa, sem tela de encontro aleatório).
3. Lutar para enfraquecer.
4. Jogar a esfera de captura (a chance aumenta com a vida baixa, efeitos e esferas melhores).
5. Ganhar experiência: criaturas e herói sobem de nível.
6. Evoluir criaturas, melhorar equipamento e o acampamento.
7. Abrir regiões novas, mais difíceis, com criaturas mais raras.

## Sistemas

| Sistema | Resumo |
|---|---|
| Criaturas | Espécie, tipo (1 ou 2), atributos base, nível 1 a 100, golpes, traço passivo, vínculo |
| Tipos | 10 tipos iniciais com vantagens e fraquezas (fogo, água, planta, terra, ar, raio, gelo, sombra, luz, metal) |
| Evolução | Por nível, por vínculo, por item, por hora do dia ou por região |
| Herói | Nível, árvore de habilidades (caçador, guerreiro, domador), equipamento e montaria |
| Combate | Tempo real no mapa: o herói ataca e esquiva, e comanda até 3 criaturas ativas |
| Captura | Chance calculada por vida, raridade, nível, esfera e habilidades do herói |
| Equipe | 6 na equipe; o resto vai para o acampamento |
| Mundo | Mapa contínuo dividido em blocos que carregam aos poucos; regiões com nível sugerido |
| Chefes | Criaturas lendárias e guardiões de região |
| Acampamento | Base do jogador, criaturas trabalhando, produção e construções |
| Economia | Moedas do jogo, loja, fabricar esferas e itens |

## Decisões técnicas (recomendação)

- **Motor: Godot 4.** Mundo aberto em tempo real precisa de um motor de jogo. O Expo/React Native, usado nos outros apps, não aguenta mundo aberto com combate em tempo real. O Godot é grátis, gera Android, iPhone e PC, e os arquivos do projeto são texto, então dá para escrever o código na VPS e abrir no PC.
- **Visual: 2D visto de cima, em pixel art.** É o caminho viável para um projeto pequeno. Um mundo 3D do tamanho dos grandes jogos do gênero exige uma equipe grande e anos de trabalho. Dá para ir para 3D numa segunda versão, depois de o jogo estar provado.
- **Primeiro só local (um jogador), depois online.** O jogo nasce com salvamento no aparelho. O modo online (trocas, batalhas entre jogadores, cooperativo) vem depois, com servidor Node no fsadesigners.com.br.
- **Regras separadas do visual.** Fórmulas de dano, captura, experiência e evolução ficam em código puro, com testes, para depois o servidor reaproveitar.
- **Na VPS só código.** O editor do Godot e os testes visuais rodam no PC (a VPS tem 1 GB de RAM).
- **Sem pagar para vencer e sem caixa surpresa.** Dinheiro real, se houver, só para visual (roupas, cores de esfera, decoração do acampamento).
