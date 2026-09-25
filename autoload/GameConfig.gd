extends Node

## Somente modo livre. Configuracoes antigas de credito sao ignoradas.
var modo_livre: bool = true

# ─────────────────────────────────────────────
# CONFIGURAÇÃO GLOBAL DO JOGO
# ─────────────────────────────────────────────

# Quantidade de jogadores (1 ou 2)
var jogadores: int = 1

# Rodadas base por jogador
var rounds_por_jogador: int = 3

# Dados persistentes da sessão
var jogador_atual: int = 1
var partida_ativa: bool = false

# Nome do cenário atual
var cenario_atual: String = ""

# Dificuldade (facil / dificil)
var dificuldade: String = "facil"

# Idioma
var idioma: String = "pt_br"

# Tempo padrão de partida
var tempo_partida: int = 120

# ─────────────────────────────────────────────
# RESET DE PARTIDA
# ─────────────────────────────────────────────
func resetar_partida() -> void:
	jogadores = clamp(jogadores, 1, 2)
	jogador_atual = 1
	partida_ativa = false


# ─────────────────────────────────────────────
# CONFIGURA JOGADORES
# ─────────────────────────────────────────────
func configurar_jogadores(qtd: int) -> void:
	jogadores = clamp(qtd, 1, 2)
	jogador_atual = 1


# ─────────────────────────────────────────────
# TROCA PLAYER
# ─────────────────────────────────────────────
func proximo_jogador() -> int:
	if jogadores <= 1:
		jogador_atual = 1
		return jogador_atual

	jogador_atual += 1

	if jogador_atual > jogadores:
		jogador_atual = 1

	return jogador_atual


# ─────────────────────────────────────────────
# RETORNA TEXTO PLAYER
# ─────────────────────────────────────────────
func texto_player() -> String:
	if jogadores <= 1:
		return "1 PLAYER"

	return "PLAYER %d" % jogador_atual
