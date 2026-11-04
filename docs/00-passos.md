# Mythera: passos

Lista de tudo o que vamos fazer. Cada passo concluído recebe ✅ e a lista atualizada é mostrada ao dono.

Legenda: ✅ feito | 🔶 em andamento | ⬜ falta

Base: o GDD do dono (`referencia/mythera-gdd-1.0.pdf`), resumido em `01-conceito.md` e analisado em `02-analise-gdd.md`. Tudo original: nome, criaturas, arte, músicas e mapa. Sem pagar para vencer e sem caixa surpresa.

## 0. Planejamento

- ✅ Pasta do projeto e primeira lista de passos (2026-11-04)
- ✅ GDD Mythera 1.0 recebido e estudado; análise em `02-analise-gdd.md` (2026-11-04)
- ✅ Motor: Godot 4 em 3D (escolha do dono em 2026-11-04; versão estável atual: 4.7.2)
- ✅ Plataformas: navegador primeiro, depois Android e iPhone (confirmado pelo dono em 2026-11-04), com o renderizador Compatibility (o único que roda no navegador) desde o começo
- 🔶 Controles de toque na tela (analógico, câmera e botões, vários dedos), além de teclado, mouse e controle (2026-11-04) (falta o dono testar no celular)
- ⬜ Pesquisar o nome "Mythera" (marca e lojas) e confirmar
- ⬜ Redesenhar o Voltiri para não lembrar o Pikachu
- 🔶 Tabela de elementos e fórmula de dano: proposta em `03-regras.md` e no código (2026-11-04) (falta o dono aprovar)
- 🔶 Variação individual de atributos: bônus de 0 a 10% (2026-11-04) (falta o dono aprovar)
- 🔶 Regras do protótipo em `03-regras.md` (2026-11-04) (falta o dono aprovar)

## 1. Semana 1: fundação

- ⬜ Instalar o Godot 4.7.2 e o Blender no PC (dono)
- ✅ Projeto Godot 4.7.2 em terceira pessoa, renderizador Compatibility (navegador, Android e iPhone) (2026-11-04)
- ✅ Estrutura de pastas: `cenas/`, `scripts/` (regras puras em `scripts/regras/`), `dados/`, `testes/`, `publicar/` (2026-11-04)
- 🔶 Repositório `github.com/scaramelo1/mythera` (falta o dono criar no GitHub e dar o push)
- ✅ Mapa de testes: chão, muros, rampa, plataforma, escada, saltos, pilares, pedras e cristais (2026-11-04)
- 🔶 Herói: andar (WASD), câmera no mouse, pular (Espaço) e esquivar (Shift), também por controle; teste automático da cena passou (2026-11-04) (falta o dono jogar)
- ✅ Testes sem abrir o jogo: 20 testes das regras e 1 da cena (`testes/`) (2026-11-04)
- ✅ Exportação pronta para navegador e Android (`export_presets.cfg`) e script para publicar no site (`publicar/publicar-web.sh`) (2026-11-04)
- ⬜ Primeira versão no navegador em fsadesigners.com.br/mythera (o dono exporta no PC e envia)

## 2. Semana 2: primeira criatura

- ⬜ Criatura base, com modelo provisório e colisão
- ⬜ Vida, ataque, defesa, nível e taxa de captura
- ⬜ Patrulha e perseguição simples
- ⬜ Dano básico (botão esquerdo e Q)
- ⬜ Barra de vida em cima da criatura

## 3. Semana 3: captura e coleção

- ✅ Dados da espécie (`dados/especies.json`) separados de cada criatura (`scripts/regras/criatura.gd`), com bônus próprio (2026-11-04)
- ⬜ Núcleo de Vínculo no inventário (bônus dos núcleos já nas regras)
- 🔶 Captura com a fórmula do GDD: regra pronta (`scripts/regras/captura.gd`) (2026-11-04); falta no jogo, de perto, com a tecla G
- ✅ Testes obrigatórios nas regras: sucesso, falha, sem núcleos, fora do alcance, equipe cheia e salvar depois de capturar (2026-11-04)
- ⬜ Tela da coleção
- 🔶 Salvar e carregar: regra pronta (`scripts/regras/salvamento.gd`) (2026-11-04); falta ligar no jogo

## 4. Semana 4: progressão e primeira versão para testar

- 🔶 Experiência e níveis (50 × L^1,5): regra pronta (2026-11-04); falta no jogo
- 🔶 Evolução Flarin → Flarvex no nível 18: regra pronta (2026-11-04); falta a troca de aparência no jogo
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
