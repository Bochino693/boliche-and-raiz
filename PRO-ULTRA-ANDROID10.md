# Dragon Bowling na Pro Ultra 4K / Android 10

Esta variante parte do projeto atualizado `boliche-and-raiz`. Preserva as cenas, o trajeto da bola, o placar, o som, os efeitos e os resultados. O HDMI permanece em paisagem; o canvas do jogo, de 1024 × 1536, gira internamente para o monitor instalado em pé. O APK usa ARM32 e ARM64, OpenGL Compatibility e modo imersivo.

## Zero Delay

| Função | Ação Godot | Índice do botão USB |
| --- | --- | ---: |
| Jogada Z | `input_z` | 2 |
| Jogada X | `input_x` | 0 |
| Jogada C | `input_c` | 1 |
| Jogada V | `input_v` | 3 |
| Jogada B, R1 | `input_b` | 5 |
| START | `input_start` | 6 |
| SELECT | `input_credit` | 7 |
| L3, configurações | `input_teste` | 8 |

### Botões: só a placa Zero Delay

Os comandos do jogo vêm **somente** da placa Zero Delay. Teclado, controle remoto da TV Box (OK, MENU, VOLTAR) e as ações `ui_*` do Godot não fazem nada, e o VOLTAR do remoto não fecha mais o jogo.

O Android numera os botões da placa de outro jeito que o Windows. Para acertar a ordem na TV Box:

1. No menu, **segure qualquer botão da placa por 5 segundos** (ou aperte L3). Abre a tela **CONFIGURAR BOTÕES DA PLACA**.
2. Aperte, na ordem pedida: START, Z (quadrado), X, C (bolinha), V (triângulo), B (R1), SELECT e L3.
3. A linha **SINAL RECEBIDO** mostra na hora o que a placa enviou (botão ou tecla), o que serve de diagnóstico. Um botão já usado é recusado. No fim aparece **PRONTO!** e o mapeamento fica gravado na TV Box.

A placa é aceita do jeito que o Android a entregar: como botão de joystick ou, nas placas genéricas que se apresentam como teclado, como tecla. Só as teclas aprendidas nessa tela contam. Se ninguém apertar nada por 20 segundos, a tela volta ao menu sem alterar nada. Sem mapeamento gravado, valem os índices do Input Map da tabela acima.

### Partida

O jogo funciona em modo livre. START abre a escolha de um ou dois jogadores. Sem um segundo START, inicia com um jogador após 3 segundos; com o segundo START, inicia com dois jogadores após 0,35 segundo.

Não há tela de carregamento: a pista é carregada em segundo plano enquanto o menu está na tela. No START, a última imagem do menu se desfaz por cima enquanto a pista monta (painéis e pinos entrando). Nenhuma tela cinza aparece entre as telas.

### Desempenho na TV Box

- A resolução de desenho é a original (nítida na saída HDMI).
- O brilho animado das canaletas voltou na TV Box. As máscaras vêm prontas em `sprites/pista_mascara.png` (gerada por `tools/gerar_mascara_pista.py`); cerca de 80% da tela não tem brilho e pula a conta. O shader é compilado ainda no menu.
- As animações de montagem da pista rodam na velocidade normal.

No Android esta variante exporta usando o APK pronto do Godot, sem Gradle: a Zero Delay funciona via HID, mas LEDs conectados ao Arduino USB não funcionam neste APK. A saída COM4 para LED segue disponível nos testes no PC.

## Gerar o APK no Windows

Extraia o ZIP inteiro em uma pasta nova e execute `GERAR_APK_PRO_ULTRA.bat`. É necessário ter Godot 4.6.1, JDK 17, Android SDK e os Export Templates 4.6.1; o BAT baixa os templates se estiverem ausentes. A exportação chama o Godot diretamente, seguindo o fluxo do `GERAR_APK_TX9.ps1` do projeto original e evitando a sessão extra de importação que falha no Windows. O BAT corrige no preset as opções que só funcionam com Gradle: Min SDK, SDK Alvo e a inclusão no launcher específico da Android TV. O APK pode ser instalado e aberto na TV Box pelo gerenciador de arquivos. O BAT fica aberto e grava `build/android/GERACAO-COMPLETA.log`. O Godot exporta em `build/android` (junto com os arquivos auxiliares da assinatura, como o `.idsig`); a pasta `APK-Pronto` é esvaziada a cada geração e recebe **somente o APK**. O APK sai em `APK-Pronto/DragonBowling-Pro-Ultra-Android10.apk`. Se a imagem ficar de cabeça para baixo no monitor em pé, execute `GERAR_APK_PRO_ULTRA.bat -Giro -1`.

Se outro APK `com.lazersport.dragonbowling` já estiver instalado com assinatura diferente, faça backup dos dados antes de desinstalá-lo. Confirme na própria Pro Ultra os índices de botões que o firmware da Zero Delay apresenta: algumas placas enviam outros índices. A compilação e os controles físicos precisam desse teste no equipamento.
