extends Node

## OS COMANDOS DO JOGO VÊM DA PLACA ZERO DELAY.
##
## Sem mapeamento gravado, valem os botões de joystick do Input Map do
## projeto. Teclado e controle remoto não fazem nada; as ações "ui_*" do
## Godot (ENTER, espaço, botão 0 de qualquer joystick) são desligadas.
##
## MAPEAMENTO GRAVADO NA TV BOX. O Android numera os botões da placa de
## outro jeito que o Windows. Na tela de CONFIGURAÇÃO (L3, ou segurar
## qualquer botão da placa por 5 segundos no menu) o jogo pede um botão
## de cada vez, na sequência, e grava em user://controles_zero_delay.cfg.
## A placa vale do jeito que ela se apresentar ao Android: como joystick
## (botão) ou, em placas genéricas no modo teclado, como tecla. Só as
## teclas aprendidas ali contam; nenhuma outra tecla faz nada.

const ARQUIVO := "user://controles_zero_delay.cfg"

## A sequência do assistente: ação, nome na tela.
const SEQUENCIA: Array = [
	["input_start", "START"],
	["input_z", "JOGADA Z  ·  QUADRADO"],
	["input_x", "JOGADA X  ·  X"],
	["input_c", "JOGADA C  ·  BOLINHA"],
	["input_v", "JOGADA V  ·  TRIÂNGULO"],
	["input_b", "JOGADA B  ·  R1"],
	["input_credit", "SELECT  ·  CRÉDITO"],
	["input_teste", "L3  ·  CONFIGURAÇÃO"],
]

const JOGADAS := {
	"input_z": "Z",
	"input_x": "X",
	"input_c": "C",
	"input_v": "V",
	"input_b": "B",
}

## Segurar qualquer botão da placa por este tempo no menu abre a
## configuração — a saída de emergência se o mapeamento estiver errado.
const SEGURAR_PARA_CONFIGURAR_MS := 5000
const CENA_CONFIGURACAO := "res://scene/configuracao_tvbox.tscn"
const CENA_MENU := "res://scene/Main Menu.tscn"

var mapeamento_gravado := false
## Teclas que o assistente aprendeu como botões da placa.
var _teclas_da_placa := {}
var _segurado_desde := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_desligar_acoes_de_interface()
	_carregar()


## As ações "ui_*" vêm de fábrica ligadas a ENTER, espaço, setas e ao
## botão 0 de qualquer joystick. Sem elas, nenhum botão aciona a
## interface por baixo do jogo.
func _desligar_acoes_de_interface() -> void:
	for acao: StringName in InputMap.get_actions():
		if String(acao).begins_with("ui_"):
			InputMap.action_erase_events(acao)


## Um código por ação: >= 0 é botão de joystick; "tecla:<código>" é tecla.
func _carregar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO) != OK:
		return
	var botoes := {}
	for item: Array in SEQUENCIA:
		var acao: String = item[0]
		if cfg.has_section_key("botoes", acao):
			botoes[acao] = cfg.get_value("botoes", acao)
	if not botoes.is_empty():
		_aplicar(botoes)
		mapeamento_gravado = true


func gravar(botoes: Dictionary) -> void:
	var cfg := ConfigFile.new()
	for acao: String in botoes:
		cfg.set_value("botoes", acao, botoes[acao])
	cfg.save(ARQUIVO)
	_aplicar(botoes)
	mapeamento_gravado = true


func _aplicar(botoes: Dictionary) -> void:
	_teclas_da_placa.clear()
	for acao: String in botoes:
		var codigo = botoes[acao]
		if not InputMap.has_action(acao):
			InputMap.add_action(acao, 0.2)
		InputMap.action_erase_events(acao)
		var texto := str(codigo)
		if texto.begins_with("tecla:"):
			var tecla := int(texto.substr(6))
			var ev := InputEventKey.new()
			ev.physical_keycode = tecla as Key
			InputMap.action_add_event(acao, ev)
			_teclas_da_placa[tecla] = true
		else:
			var ev := InputEventJoypadButton.new()
			ev.device = -1
			ev.button_index = int(texto.trim_prefix("botao:")) as JoyButton
			InputMap.action_add_event(acao, ev)


## Código gravável de um evento: "botao:N" (joystick) ou "tecla:N";
## vazio se o evento não é botão nem tecla.
static func codigo_do_evento(event: InputEvent) -> String:
	if event is InputEventJoypadButton:
		return "botao:%d" % int(event.button_index)
	if event is InputEventKey:
		var k := event as InputEventKey
		var fisica := int(k.physical_keycode) if k.physical_keycode != KEY_NONE else int(k.keycode)
		if fisica != KEY_NONE:
			return "tecla:%d" % fisica
	return ""


static func texto_do_codigo(codigo: String) -> String:
	if codigo.begins_with("tecla:"):
		return "TECLA %s" % OS.get_keycode_string(int(codigo.substr(6)))
	return "BOTÃO %d" % int(codigo.trim_prefix("botao:"))


func texto_de(acao: String) -> String:
	for ev in InputMap.action_get_events(acao):
		if ev is InputEventJoypadButton:
			return "BOTÃO %d" % int(ev.button_index)
		if ev is InputEventKey:
			return "TECLA %s" % OS.get_keycode_string(ev.physical_keycode)
	return "-"


## É um botão da placa? Joystick sempre; tecla só se o assistente aprendeu.
func eh_da_placa(event: InputEvent) -> bool:
	if event.is_echo():
		return false
	if event is InputEventJoypadButton:
		return true
	if event is InputEventKey and not _teclas_da_placa.is_empty():
		var k := event as InputEventKey
		var fisica := int(k.physical_keycode) if k.physical_keycode != KEY_NONE else int(k.keycode)
		return _teclas_da_placa.has(fisica)
	return false


func eh_start(event: InputEvent) -> bool:
	return eh_da_placa(event) and event.is_action_pressed("input_start")


func eh_config(event: InputEvent) -> bool:
	return eh_da_placa(event) and event.is_action_pressed("input_teste")


func eh_credito(event: InputEvent) -> bool:
	return eh_da_placa(event) and event.is_action_pressed("input_credit")


func tecla_jogada(event: InputEvent) -> String:
	if not eh_da_placa(event):
		return ""
	for acao: String in JOGADAS:
		if event.is_action_pressed(acao):
			return JOGADAS[acao]
	return ""


## Qualquer botão da placa conta como "alguém está jogando".
func eh_atividade(event: InputEvent) -> bool:
	return eh_da_placa(event) and event.is_pressed()


# ----------------------------------------------------- saída de emergência
## Segurar um botão da placa (ou, se a placa estiver no modo teclado, uma
## tecla dela) por 5 s no menu abre a configuração.
func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton or event is InputEventKey):
		return
	if event.is_echo():
		return
	var chave := codigo_do_evento(event)
	if chave == "":
		return
	if event.is_pressed():
		if not _segurado_desde.has(chave):
			_segurado_desde[chave] = Time.get_ticks_msec()
	else:
		_segurado_desde.erase(chave)


func _process(_delta: float) -> void:
	if _segurado_desde.is_empty():
		return
	var cena := get_tree().current_scene
	if cena == null or cena.scene_file_path != CENA_MENU:
		# Fora do menu não conta: um aperto esquecido não pode abrir a
		# configuração assim que o menu voltar.
		_segurado_desde.clear()
		return
	var agora := Time.get_ticks_msec()
	for chave: String in _segurado_desde:
		if agora - int(_segurado_desde[chave]) >= SEGURAR_PARA_CONFIGURAR_MS:
			_segurado_desde.clear()
			get_tree().change_scene_to_file.call_deferred(CENA_CONFIGURACAO)
			return
