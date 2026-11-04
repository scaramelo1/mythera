# Mythera: passos

Lista de tudo o que vamos fazer. Cada passo concluído recebe ✅ e a lista atualizada é mostrada ao dono.

Legenda: ✅ feito | 🔶 em andamento | ⬜ falta

Base: o GDD do dono (`referencia/mythera-gdd-1.0.pdf`), resumido em `01-conceito.md` e analisado em `02-analise-gdd.md`. Tudo original: nome, criaturas, arte, músicas e mapa. Sem pagar para vencer e sem caixa surpresa.

## 0. Planejamento

- ✅ Pasta do projeto e primeira lista de passos (2026-11-04)
- ✅ GDD Mythera 1.0 recebido e estudado; análise em `02-analise-gdd.md` (2026-11-04)
- ✅ Motor: Godot 4 em 3D (escolha do dono em 2026-11-04; versão estável atual: 4.7.2)
- ⬜ Plataformas: navegador primeiro, depois Android e iPhone, com o renderizador Compatibility (o único que roda no navegador) desde o começo
- ⬜ Controles de toque na tela, além de teclado, mouse e controle
- ⬜ Pesquisar o nome "Mythera" (marca e lojas) e confirmar
- ⬜ Redesenhar o Voltiri para não lembrar o Pikachu
- ⬜ Tabela de elementos (vantagens e fraquezas) e fórmula de dano
- ⬜ Variação individual de atributos (bônus aleatório de cada criatura)
- ⬜ Regras do protótipo aprovadas (`03-regras.md`)

## 1. Semana 1: fundação

- ⬜ Instalar o motor e o Blender no PC
- ⬜ Criar o projeto em terceira pessoa, para PC
- ⬜ Estrutura de pastas e prefixos (BP_, WBP_, ST_, DT_, ABP_, DA_ ou o equivalente no motor escolhido)
- ⬜ Repositório no GitHub (com Git LFS se for Unreal)
- ⬜ Mapa de testes com terreno e obstáculos
- ⬜ Herói: andar (WASD), câmera no mouse, pular (Espaço) e esquivar (Shift)

## 2. Semana 2: primeira criatura

- ⬜ Criatura base, com modelo provisório e colisão
- ⬜ Vida, ataque, defesa, nível e taxa de captura
- ⬜ Patrulha e perseguição simples
- ⬜ Dano básico (botão esquerdo e Q)
- ⬜ Barra de vida em cima da criatura

## 3. Semana 3: captura e coleção

- ⬜ Dados da espécie separados dos dados de cada criatura capturada
- ⬜ Núcleo de Vínculo no inventário
- ⬜ Captura de perto com a tecla G e a fórmula do GDD
- ⬜ Testes obrigatórios: sucesso, falha, sem núcleos, fora do alcance, equipe cheia e salvar depois de capturar
- ⬜ Tela da coleção
- ⬜ Salvar e carregar as criaturas capturadas

## 4. Semana 4: progressão e primeira versão para testar

- ⬜ Experiência e níveis (50 × L^1,5) para herói e criatura
- ⬜ Uma evolução com troca de aparência
- ⬜ Invocar e recolher a companheira (R) e dar comandos (F)
- ⬜ Companheira: seguir, detectar inimigo, atacar ou defender, usar habilidade e voltar
- ⬜ Inimigo mais forte (minichefe)
- ⬜ Versão para o navegador, publicada no site para testar
- ⬜ Conferir os critérios do protótipo pronto (seção 15 do GDD)

## 5. Primeira região: Vale Esmeralda (cerca de 500 × 500 m)

- ⬜ Terreno, vila pequena e pontos de interesse
- ⬜ Dia e noite, mudando as criaturas que aparecem
- ⬜ Geradores de criaturas por habitat e horário
- ⬜ Flarin, Aquori e Mosshell completos (fogo, água e natureza)
- ⬜ Arremesso do núcleo (projétil), com efeitos e animação

## 6. Herói e sobrevivência leve

- ⬜ Atributos vigor, força, essência e agilidade, com pontos a cada nível
- ⬜ Trilhas de talentos: guerreiro, vinculador, explorador, elementalista e artesão
- ⬜ Coleta de madeira, pedra e cristais de Essência
- ⬜ Estação de fabricação: núcleos de vários níveis e poções
- ⬜ Base com baú e ponto de descanso
- ⬜ Armaduras e acessórios que mudam a aparência do herói

## 7. Missões e história

- ⬜ Missões guardadas como dados, sem reprogramar a lógica
- ⬜ Prólogo (Despertar do Vinculador) e Capítulo I (Primeiro Vínculo)
- ⬜ Capítulo II (Ecos da Ruptura): ruínas no Vale Esmeralda
- ⬜ Missões secundárias: resgate, coleta, exploração e combate

## 8. Arte e som

- ⬜ Arte própria das criaturas (as imagens do GDD são só inspiração)
- ⬜ Modelos, animações e formas evoluídas
- ⬜ Herói com animações
- ⬜ Telas e interface
- ⬜ Músicas e sons

## 9. Conteúdo do jogo completo

- ⬜ 20 primeiras criaturas e depois os 10 elementos
- ⬜ Capítulos III a V
- ⬜ Regiões: Terras de Ignis, Cordilheira Glacial, Floresta de Lumina, Deserto de Arkan e Ilhas Celestiais
- ⬜ Montarias e criaturas trabalhando na base
- ⬜ Guardiões e chefes

## 10. Lançamento

- ⬜ Testes com amigos e ajuste de equilíbrio
- ⬜ Página do jogo no site, trailer e imagens
- ⬜ Android: APK para testes e AAB para a Google Play (teste fechado com 12 pessoas por 14 dias)
- ⬜ iPhone: Apple Developer (US$ 99 por ano) e build feita num Mac com Xcode (Mac alugado na nuvem ou GitHub Actions com macOS); enquanto isso, o iPhone joga pelo navegador
- ⬜ Classificação etária e política de privacidade
- ⬜ PC (Steam ou itch.io), se fizer sentido
- ⬜ Online só depois, se fizer sentido
