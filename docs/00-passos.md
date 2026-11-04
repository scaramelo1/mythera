# Feralis: passos

Lista de tudo o que vamos fazer. Cada passo concluído recebe ✅ e a lista atualizada é mostrada ao dono.

Legenda: ✅ feito | 🔶 em andamento | ⬜ falta

Regras: jogo de captura de criaturas em mundo aberto, mas tudo original (nome, criaturas, arte, músicas e mapa). Sem pagar para vencer e sem caixa surpresa. Na VPS só código; o editor do Godot roda no PC. Detalhes em `01-conceito.md`.

## 1. Definir o jogo

- ✅ Ideia geral e laço principal: explorar, lutar, capturar, treinar, evoluir (`01-conceito.md`) (2026-11-04)
- ⬜ Nome definitivo e ícone (hoje: "Feralis", provisório)
- ⬜ Confirmar o motor (recomendado: Godot 4) e o visual (recomendado: 2D visto de cima, pixel art)
- ⬜ Confirmar onde o jogo roda primeiro: celular Android, PC ou os dois
- ⬜ Confirmar o combate: tempo real no mapa (recomendado) ou por turnos
- ⬜ História curta e objetivo final (ex.: proteger o mundo dos guardiões corrompidos)
- ⬜ Lista dos 10 tipos e a tabela de vantagens e fraquezas
- ⬜ Primeiras 30 criaturas: nome, tipo, atributos, golpes, traço e de onde evoluem
- ⬜ Regras de evolução: por nível, vínculo, item, hora do dia e região
- ⬜ Herói: atributos, níveis, árvore de habilidades (caçador, guerreiro, domador) e equipamento
- ⬜ Fórmulas: dano, captura, experiência por nível e ganho de vínculo
- ⬜ Mapa do mundo no papel: regiões, nível sugerido de cada uma e quais criaturas vivem em cada lugar
- ⬜ Documento de regras (`02-regras.md`) aprovado pelo dono

## 2. Ferramentas

- ✅ Pasta do projeto em `/var/www/feralis`, com a lista de passos e o conceito (2026-11-04)
- ⬜ Repositório `github.com/scaramelo1/feralis` (o dono cria no GitHub e dá o push)
- ⬜ Godot 4 instalado no PC do dono
- ⬜ Projeto Godot criado (pastas, resolução, controles de teclado, controle e toque)
- ⬜ Testes das regras com GUT (ferramenta de testes do Godot), rodando no PC

## 3. Motor do jogo, sem gráficos

- ⬜ Criatura: espécie, nível, atributos, golpes, vida, experiência e vínculo
- ⬜ Tabela de tipos e cálculo de dano
- ⬜ Fórmula de captura
- ⬜ Experiência, subir de nível e aprender golpes
- ⬜ Evolução com todas as condições
- ⬜ Herói: nível, pontos de habilidade e equipamento
- ⬜ Equipe de 6 e caixa do acampamento
- ⬜ Inventário, itens e loja
- ⬜ Salvar e carregar o jogo
- ⬜ Testes de todas as regras

## 4. Primeiro protótipo jogável (uma região pequena)

- ⬜ Herói andando no mapa, com câmera seguindo
- ⬜ Uma região de teste com 5 criaturas andando livres
- ⬜ Criaturas com comportamento: andar, fugir, atacar, dormir à noite
- ⬜ Combate em tempo real: herói ataca e esquiva, criaturas usam golpes
- ⬜ Chamar e recolher criaturas da equipe na luta
- ⬜ Jogar a esfera e capturar, com animação de tentativa
- ⬜ Tela da equipe e da criatura (atributos, golpes, nível)
- ⬜ Subir de nível e evoluir na tela, com animação
- ⬜ Salvar no aparelho
- ⬜ O dono jogar e aprovar a sensação do combate e da captura

## 5. Mundo aberto

- ⬜ Mapa contínuo dividido em blocos que carregam e descarregam conforme o herói anda
- ⬜ 4 regiões iniciais (ex.: floresta, praia, montanha, deserto), com nível crescente
- ⬜ Dia e noite e clima (chuva, neblina, neve) mudando as criaturas que aparecem
- ⬜ Pontos de viagem rápida
- ⬜ Montaria: algumas criaturas levam o herói (andar mais rápido, nadar, voar depois)
- ⬜ Minimapa e mapa completo, com marcações
- ⬜ Cavernas e lugares escondidos com criaturas raras
- ⬜ Desempenho no celular: testar num aparelho simples

## 6. Progressão e conteúdo

- ⬜ Árvore de habilidades do herói funcionando
- ⬜ Equipamentos (armas, roupas, acessórios) e fabricação
- ⬜ Tipos de esfera (comum, boa, ótima, especiais por tipo)
- ⬜ Missões principais (história) e missões secundárias
- ⬜ Personagens do mundo (vendedores, treinadores, mestres)
- ⬜ Chefes: guardiões de cada região e criaturas lendárias
- ⬜ Registro de criaturas (vistas e capturadas), com recompensas
- ⬜ Chegar a 100 criaturas

## 7. Acampamento

- ⬜ Base do jogador, num lugar escolhido do mapa
- ⬜ Criaturas trabalhando conforme o tipo (coletar, minerar, plantar, cozinhar)
- ⬜ Construções e melhorias
- ⬜ Cuidar das criaturas (comida e descanso), que sobe o vínculo

## 8. Arte e som

- ⬜ Estilo visual definido com uma tela de exemplo
- ⬜ Herói com animações (andar, correr, atacar, esquivar, jogar a esfera)
- ⬜ Criaturas com animações (parada, andar, atacar, levar dano, desmaiar), e as formas evoluídas
- ⬜ Blocos do mapa de cada região
- ⬜ Efeitos dos golpes por tipo
- ⬜ Telas e botões
- ⬜ Músicas por região, de batalha e de chefe
- ⬜ Sons de golpes, captura e evolução

## 9. Servidor e contas

- ⬜ Servidor Node no fsadesigners.com.br, como o `prancheta-api`
- ⬜ Login com Google (e Sign in with Apple, exigido pela Apple)
- ⬜ Salvamento na nuvem
- ⬜ Servidor conferir as ações importantes (captura, experiência, itens) para evitar trapaça
- ⬜ Exclusão de conta dentro do jogo (exigido pelas lojas)

## 10. Parte online

- ⬜ Amigos por código
- ⬜ Trocar criaturas
- ⬜ Batalhas entre jogadores
- ⬜ Modo cooperativo: explorar e enfrentar chefes juntos
- ⬜ Ranking

## 11. Testes de verdade

- ⬜ APK para o dono e amigos
- ⬜ Página de download no site
- ⬜ Ajustar equilíbrio: dano, captura, experiência e dificuldade das regiões
- ⬜ Corrigir travamentos e desempenho

## 12. Lançamento

- ⬜ Google Play: conta de desenvolvedor e teste fechado com 12 pessoas por 14 dias
- ⬜ App Store: Apple Developer e build do iPhone
- ⬜ Steam (opcional, para PC)
- ⬜ Política de privacidade e classificação etária
- ⬜ Página do jogo no site, trailer e imagens

## 13. Depois de lançar

- ⬜ Regiões novas e criaturas novas
- ⬜ Eventos de época com criaturas especiais
- ⬜ Itens visuais com dinheiro real (sem vantagem no jogo)
