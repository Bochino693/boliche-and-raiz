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

- Ao abrir o app aparece a abertura animada **Lazer & Sport GAMES** (alvo com impacto e faíscas, a placa sobe, "GAMES" letra por letra, brilho na placa). Enquanto ela roda, o menu carrega. Não há mais tela preta: a imagem de inicialização do Android já é o primeiro quadro da abertura.
- O logo vem em versões de vários tamanhos (`sprites/marca/`, geradas por `tools/gerar_marca.py`). O jogo usa a versão certa para o tamanho real na tela, e todas as imagens usam mipmaps, então logos e pinos reduzidos não ficam serrilhados.
- O brilho animado das canaletas roda na TV Box. As máscaras vêm prontas em `sprites/pista_mascara.png` (`tools/gerar_mascara_pista.py`).

No Android esta variante exporta usando o APK pronto do Godot, sem Gradle: a Zero Delay funciona via HID, mas LEDs conectados ao Arduino USB não funcionam neste APK. A saída COM4 para LED segue disponível nos testes no PC.

## Gerar o APK no Windows

Extraia o ZIP inteiro em uma pasta nova e execute `GERAR_APK_PRO_ULTRA.bat`. É necessário ter Godot 4.6.1, JDK 17, Android SDK e os Export Templates 4.6.1; o BAT baixa os templates se estiverem ausentes. A exportação chama o Godot diretamente, seguindo o fluxo do `GERAR_APK_TX9.ps1` do projeto original e evitando a sessão extra de importação que falha no Windows. O BAT corrige no preset as opções que só funcionam com Gradle: Min SDK, SDK Alvo e a inclusão no launcher específico da Android TV. O APK pode ser instalado e aberto na TV Box pelo gerenciador de arquivos. O BAT fica aberto e grava `build/android/GERACAO-COMPLETA.log`. O Godot exporta em `build/android` (junto com os arquivos auxiliares da assinatura, como o `.idsig`); a pasta `APK-Pronto` é esvaziada a cada geração e recebe **somente o APK**. O APK sai em `APK-Pronto/DragonBowling-Pro-Ultra-Android10.apk`. Se a imagem ficar de cabeça para baixo no monitor em pé, execute `GERAR_APK_PRO_ULTRA.bat -Giro -1`.

Se outro APK `com.lazersport.dragonbowling` já estiver instalado com assinatura diferente, faça backup dos dados antes de desinstalá-lo. Confirme na própria Pro Ultra os índices de botões que o firmware da Zero Delay apresenta: algumas placas enviam outros índices. A compilação e os controles físicos precisam desse teste no equipamento.
