# Dragon Bowling na Pro Ultra 4K / Android 10

Esta variante parte do projeto atualizado `boliche-and-raiz`. Preserva as cenas, o trajeto da bola, o placar, o som, os efeitos e os resultados. O HDMI permanece em paisagem; o canvas do jogo, de 1024 × 1536, gira internamente para o monitor instalado em pé. O APK usa ARM32 e ARM64, OpenGL Compatibility e modo imersivo.

## Zero Delay

A placa desta máquina está no **modo teclado**: cada botão manda uma tecla (Espaço, setas, A, S, D, F, 1, 5, G, C, V, X, 9). O jogo já vem ligado assim:

| Botão da placa | Função no jogo | Tecla | Índice joystick |
| --- | --- | :---: | ---: |
| STR | START | 1 ou Espaço | 6 |
| Quadrado | jogada esquerda (Z) | A | 2 |
| X | meio esquerdo (X) | S | 0 |
| Bolinha | strike, centro (C) | D | 1 |
| Triângulo | meio direito (V) | F | 3 |
| R1 | jogadas extremas (B) | G | 5 |
| SELECT | crédito | 5 | 7 |
| L3 | configuração | 9 | 8 |

Se na máquina algum botão cair na função errada, refaça pela tela de configuração (abaixo). Leva uns 10 segundos.

### Configurar os botões (rápido)

1. No menu, **segure qualquer botão da placa por 5 segundos** (ou aperte L3). Abre **CONFIGURAR BOTÕES DA PLACA**.
2. Aperte, na ordem: **STR, Quadrado, X, Bolinha, Triângulo, R1**.
3. SELECT e L3 são opcionais: aperte ou aguarde 4 segundos para pular.
4. Aparece **PRONTO!** e o jogo volta ao menu. O mapeamento fica gravado na TV Box.

A linha **SINAL RECEBIDO** mostra na hora o que a placa enviou (tecla ou botão). No menu, um botão sem função mostra um aviso com o nome da tecla e como configurar.

Só as teclas ligadas a uma função do jogo fazem alguma coisa. Setas, OK e as teclas do controle remoto não fazem nada no jogo. O **VOLTAR do controle remoto fecha o app**, como antes.

### Partida

O jogo funciona em modo livre. START abre a escolha de um ou dois jogadores. Sem um segundo START, inicia com um jogador após 3 segundos; com o segundo START, inicia com dois jogadores após 0,35 segundo.

Não há tela de carregamento: a pista é carregada em segundo plano enquanto o menu está na tela. No START, a última imagem do menu se desfaz por cima enquanto a pista monta (painéis e pinos entrando). Nenhuma tela cinza aparece entre as telas.

### Abertura e imagem

- Ao abrir o app aparece a abertura animada **Lazer & Sport GAMES**. A imagem de inicialização do Android é só o fundo escuro, igual ao primeiro quadro da abertura, então não há logo parado. O emblema só aparece na montagem: a placa sobe, o alvo sai de trás dela com impacto e faíscas, "GAMES" entra letra por letra e um brilho passa pela placa. Enquanto isso, o menu carrega.
- O logo vem em versões de vários tamanhos (`sprites/marca/`, geradas por `tools/gerar_marca.py`), e todas as imagens usam mipmaps: logos e pinos reduzidos não ficam serrilhados.
- O brilho animado das canaletas roda na TV Box (`sprites/pista_mascara.png`, `tools/gerar_mascara_pista.py`).

### Jogada lisa, som junto

- **Jogada guardada:** um sensor acionado enquanto a pista ainda não aceita jogada (pinos caindo, resultado, troca de rodada) não se perde mais. A jogada sai assim que a pista liberar, em até 10 s. Um segundo sensor acionado até 1,2 s depois de um lançamento é tratado como a mesma bola.
- **Esperas menores entre jogadas:** depois de um strike, a pista ficava até 6 s sem aceitar a placa; agora são cerca de 4,7 s, com as animações rodando normalmente.
- **Som junto com a bola:** o som do lançamento e o da bola rolando esperam o quadro em que a bola já foi desenhada, mais 60 ms (`GameConfig.atraso_som_jogada`). Antes o som saía antes da imagem.
- A entrada da placa é processada o mais cedo possível em cada quadro (`input_devices/buffering/agile_event_flushing`).
- O texto amarelo no alto da pista ("PREPARE-SE PARA JOGAR!" etc.) saiu, porque repetia o aviso central.

### Leve na TV Box (sem travar)

- **Troca de tela por cortina:** a tela escurece rápido, a cena nova monta por baixo e o véu abre quando a TV Box volta ao ritmo normal. A troca antiga tirava uma foto da tela (lendo a imagem de volta da placa de vídeo), o que parava tudo na TV Box e podia mostrar a imagem girada.
- **Nada espera a fila de carregamento:** o menu pedia com `load()` arquivos que já estavam na fila de fundo (logo, máscara da pista), e a tela ficava parada até a pista inteira carregar (300 ms aqui, segundos na TV Box). Isso acabou. O START também não espera mais a pista em bloco.
- **Modal de jogadores pronto:** ele é montado escondido logo que o menu assenta, e o START só o mostra.
- **Letras preparadas no menu:** "STRIKE!", "ACERTO!", "ROUND", "1 PLAYER" etc. são letras grandes com contorno, e cada uma era desenhada pela primeira vez na hora da jogada. Agora elas são desenhadas no menu parado, uma por quadro.
- **Sem busca de fontes no sistema:** 🎳, 🏆, ★, ◆ e ▼ vêm de duas fontinhas embutidas (`fonts/emoji_do_jogo.ttf`, 13 KB, e `fonts/simbolos_do_jogo.ttf`, 5 KB, geradas por `tools/gerar_fontes_simbolos.py`). Antes o Android abria a fonte de emoji inteira do sistema na hora em que o texto aparecia.
- **Imagens grandes com compressão de vídeo (ETC2):** fundo do menu, pista e pinos são lidos direto pela placa de vídeo, sem descompactar no processador.
- **Arquivos sem uso removidos:** 20 imagens e sons que nenhum código usa saíram (cerca de 26 MB a menos no pacote, entre eles `song_play.mp3`, de 6 MB).
- Medido no PC: durante a partida, a média é de 0,7 ms de processador por quadro, sem picos. A única montagem pesada (a pista, uma vez por partida) acontece com a cortina fechada.

No Android esta variante exporta usando o APK pronto do Godot, sem Gradle: a Zero Delay funciona via HID, mas LEDs conectados ao Arduino USB não funcionam neste APK. A saída COM4 para LED segue disponível nos testes no PC.

## Gerar o APK no Windows

Extraia o ZIP inteiro em uma pasta nova e execute `GERAR_APK_PRO_ULTRA.bat`. É necessário ter Godot 4.6.1, JDK 17, Android SDK e os Export Templates 4.6.1; o BAT baixa os templates se estiverem ausentes. A exportação chama o Godot diretamente, seguindo o fluxo do `GERAR_APK_TX9.ps1` do projeto original e evitando a sessão extra de importação que falha no Windows. O BAT corrige no preset as opções que só funcionam com Gradle: Min SDK, SDK Alvo e a inclusão no launcher específico da Android TV. O APK pode ser instalado e aberto na TV Box pelo gerenciador de arquivos. O BAT fica aberto e grava `build/android/GERACAO-COMPLETA.log`. O Godot exporta em `build/android` (junto com os arquivos auxiliares da assinatura, como o `.idsig`); a pasta `APK-Pronto` é esvaziada a cada geração e recebe **somente o APK**. O APK sai em `APK-Pronto/DragonBowling-Pro-Ultra-Android10.apk`. Se a imagem ficar de cabeça para baixo no monitor em pé, execute `GERAR_APK_PRO_ULTRA.bat -Giro -1`.

Se outro APK `com.lazersport.dragonbowling` já estiver instalado com assinatura diferente, faça backup dos dados antes de desinstalá-lo. Confirme na própria Pro Ultra os índices de botões que o firmware da Zero Delay apresenta: algumas placas enviam outros índices. A compilação e os controles físicos precisam desse teste no equipamento.
