# enunciado do slide

## Ações do Player:
- Aperta Seta p/ direita => Aumenta o posicionamento X do player
- Aperta Seta p/ esquerda => Diminui o posicionamento X do player
- Aperta Espaço => Cria um objeto "míssil" no centro do player. Esse objeto tem sua posição Y incrementada a cada loop do jogo. Se o objeto colidir com uma nave inimiga, o objeto da nave e do míssil são removidos do jogo, se colidir com a parede, o objeto do míssil é removido do jogo.

## Ações das naves comuns:
- Incrementa uma unidade de X a cada passo até completar 10 passos
- Decrementa uma unidade de X a cada passo até completar 10 passos
- Decrementa 5 unidades de Y
- Repete do passo 1
- Se uma nave tocar a parede inferior o jogo acaba e o jogador perde.
- De forma aleatória, a nave atira um míssil.
- O objeto míssil é criado no centro da nave que o gerou e tem seu posicionamento Y decrementado em uma unidade a cada passo. Se o objeto míssil atingir o player, o player perde uma unidade na variável de vida. Se o míssil atingir a parede inferior, o míssil é removido do jogo.

## Ações da nave chefe:
- De forma randômica, a cada 30~50 segundos, a nave aparece no topo superior esquerdo do ambiente. 
- A nave incrementa sua posição X em 5 unidades a cada passo.
- A nave desaparece se ela chegar no canto superior direito do ambiente.

# Elementos formais

1. **Padrão de interação do jogador:** Single-player.

2. **Objetivo:** Destruir todos os alienígenas que estão se movendo de um lado para outro na parte superior da tela.

3. **Regras:**
   a. O jogador controla uma nave espacial que se move para a esquerda ou para a direita na base da tela sem ultrapassar os limites do ambiente.
   b. Os alienígenas se movem para a esquerda ou para a direita no topo da tela sem ultrapassar os limites do ambiente.
   c. A cada intervalo de tempo aleatório, uma nave alienígena chefe aparece em um dos cantos superiores da tela, anda até o canto superior oposto e some, caso não seja destruída antes.
   d. A cada intervalo de tempo os alienígenas se aproximam da base da tela.
   e. O jogador pode disparar mísseis em direção aos alienígenas.
   f. Se um alienígena for atingido por um míssil do jogador, o alienígena é destruído imediatamente.
   g. O jogador ganha pontos por cada alienígena destruído.
   h. Existem tipos de alienígenas diferentes que são pontuações diferentes.
   i. Os alienígenas podem disparar mísseis na direção do jogador.
   j. O jogador perde uma vida se for atingido por um míssil dos alienígenas ou se um alienígena tocar a base da tela.
   k. O jogo apresenta vários níveis de dificuldade, com os alienígenas se movendo cada vez mais rápido e atirando com mais frequência conforme o jogo avança.

4. **Procedimentos:**
   a. Clicar tecla para direita
   b. Clicar tecla para esquerda
   c. Clicar tecla para atirar

---

**Recursos:**
a. Vidas - Inicia com 3  
b. Pontos - Inicia com 0  
   i. Destruição de alienígena tipo 1: O jogador ganha 10 pontos.  
   ii. Destruição de alienígena tipo 2: O jogador ganha 20 pontos.  
   iii. Destruição de alienígena tipo 2: O jogador ganha 30 pontos.  
   iv. Destruição de alienígena tipo Chefe: O jogador ganha 50 pontos.  
c. Mísseis - Infinito tanto para o jogador quanto para os alienígenas  

**Limites do jogo:**
a. O jogo acontece em um ambiente virtual e fictício, sem qualquer influência no mundo real.
b. Paredes ao redor do ambiente limitam a movimentação do jogador, dos alienígenas e dos mísseis.
c. Quantidade de vidas limitam o quanto o jogador pode continuar jogando.
d. Velocidade dos alienígenas limitam o tempo que o jogador tem para agir.

**Resultado:**
a. O jogo termina quando:
   i. Todos os alienígenas em todos os níveis são destruídos.
   ii. O jogador perde todas as suas vidas.
