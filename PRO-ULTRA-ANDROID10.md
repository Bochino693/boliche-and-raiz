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

O jogo funciona em modo livre. START abre rapidamente a escolha de um ou dois jogadores. Sem um segundo START, inicia com um jogador após 3 segundos; com o segundo START, inicia com dois jogadores após 0,35 segundo. L3 abre a tela de diagnóstico dos botões. Configure os botões no Input Map do projeto (`input_start`, `input_z`, `input_x`, `input_c`, `input_v`, `input_b` e `input_teste`); o código usa estas ações sem substituí-las na inicialização. Quadrado e R1 derrubam somente um pino na faixa externa; a bolinha derruba os dez pinos quando o rack está completo. A passagem do menu para a pista conserva a imagem do menu até a cena do jogo estar pronta, sem cortina ou tela de carregamento. Apenas a placa Zero Delay possui eventos padrão no Input Map; ajuste os índices no Godot conforme a sua placa. Nenhum comando de teclado ou botão OK do controle remoto inicia a partida. O shader animado de fundo é omitido na TV Box para reduzir carga da GPU, mantendo os efeitos de bola, pinos, HUD e resultados. No Android esta variante exporta usando o APK pronto do Godot, sem Gradle: a Zero Delay funciona via HID, mas LEDs conectados ao Arduino USB não funcionarão neste APK. A saída COM4 para LED segue disponível nos testes no PC.

## Gerar o APK no Windows

Extraia o ZIP inteiro em uma pasta nova e execute `GERAR_APK_PRO_ULTRA.bat`. É necessário ter Godot 4.6.1, JDK 17, Android SDK e os Export Templates 4.6.1; o BAT baixa os templates se estiverem ausentes. A exportação chama o Godot diretamente, seguindo o fluxo do `GERAR_APK_TX9.ps1` do projeto original e evitando a sessão extra de importação que falha no Windows. O BAT corrige no preset as opções que só funcionam com Gradle: Min SDK, SDK Alvo e a inclusão no launcher específico da Android TV. O APK pode ser instalado e aberto na TV Box pelo gerenciador de arquivos. O BAT fica aberto e grava `build/android/GERACAO-COMPLETA.log`; a pasta `APK-Pronto` contém apenas o APK. O APK sai em `APK-Pronto/DragonBowling-Pro-Ultra-Android10.apk`. Se a imagem ficar de cabeça para baixo no monitor em pé, execute `GERAR_APK_PRO_ULTRA.bat -Giro -1`.

Se outro APK `com.lazersport.dragonbowling` já estiver instalado com assinatura diferente, faça backup dos dados antes de desinstalá-lo. Confirme na própria Pro Ultra os índices de botões que o firmware da Zero Delay apresenta: algumas placas enviam outros índices. A compilação e os controles físicos precisam desse teste no equipamento.
