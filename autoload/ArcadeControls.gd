extends Node

## OS COMANDOS DO JOGO VÊM SÓ DA PLACA ZERO DELAY.
##
## Teclado, controle remoto da TV Box e as ações "ui_*" do Godot não fazem
## nada no jogo. No Android isso importa: o OK do controle remoto chega
## como ENTER (que o Godot liga ao "ui_accept"), a tecla MENU do remoto
## chega como o botão 6 de joystick (o mesmo índice do START) e o botão 0
## da placa também acionava o "ui_accept".
##
## O MAPEAMENTO É GRAVADO NA TV BOX. O Android numera os botões da Zero
## Delay de outro jeito que o Windows, então o que foi mapeado no PC não
## vale lá. Na tela de CONFIGURAÇÃO (L3, ou segurar qualquer botão da
## placa por 5 segundos no menu) o jogo pede um botão de cada vez, na
## sequência, e grava em user://controles_zero_delay.cfg. Sem arquivo
## gravado, valem os índices do Input Map do projeto.

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

## Nomes de aparelho que NUNCA são a placa (controle remoto, teclado
## virtual, botões do próprio aparelho).
const NAO_E_PLACA := ["remote", "remoto", "keypad", "keyboard", "teclado", "cec",
	"gpio", "virtual", "uinput", "consumer", "mouse", "hdmi", "power", "sunxi", "meson-ir", "ir-keys", "ir_keys"]

## Nome da placa gravado pelo assistente (vazio = qualquer joystick).
var nome_da_placa := ""
var mapeamento_gravado := false

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


func _carregar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO) != OK:
		return
	nome_da_placa = str(cfg.get_value("placa", "nome", ""))
	for item: Array in SEQUENCIA:
		var acao: String = item[0]
		var indice := int(cfg.get_value("botoes", acao, -1))
		if indice >= 0:
			_ligar(acao, indice)
	mapeamento_gravado = true


func gravar(botoes: Dictionary, nome: String) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("placa", "nome", nome)
	for acao: String in botoes:
		cfg.set_value("botoes", acao, int(botoes[acao]))
		_ligar(acao, int(botoes[acao]))
	cfg.save(ARQUIVO)
	nome_da_placa = nome
	mapeamento_gravado = true


func _ligar(acao: String, indice: int) -> void:
	if not InputMap.has_action(acao):
		InputMap.add_action(acao, 0.2)
	InputMap.action_erase_events(acao)
	var ev := InputEventJoypadButton.new()
	ev.device = -1
	ev.button_index = indice as JoyButton
	InputMap.action_add_event(acao, ev)


func indice_de(acao: String) -> int:
	for ev in InputMap.action_get_events(acao):
		if ev is InputEventJoypadButton:
			return int(ev.button_index)
	return -1


## É um botão vindo da placa? Todo o resto é ignorado.
func eh_da_placa(event: InputEvent) -> bool:
	if not (event is InputEventJoypadButton):
		return false
	if event.is_echo():
		return false
	var nome := Input.get_joy_name(event.device)
	if nome_da_placa != "":
		# Com placa gravada, só ela manda.
		return nome.strip_edges() == nome_da_placa.strip_edges()
	var baixo := nome.to_lower()
	for trecho: String in NAO_E_PLACA:
		if baixo.contains(trecho):
			return false
	return true


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
func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton):
		return
	var chave := "%d:%d" % [event.device, event.button_index]
	if event.pressed:
		if not _segurado_desde.has(chave):
			_segurado_desde[chave] = Time.get_ticks_msec()
	else:
		_segurado_desde.erase(chave)


func _process(_delta: float) -> void:
	if _segurado_desde.is_empty():
		return
	var cena := get_tree().current_scene
	if cena == null or cena.scene_file_path != CENA_MENU:
		return
	var agora := Time.get_ticks_msec()
	for chave: String in _segurado_desde:
		if agora - int(_segurado_desde[chave]) >= SEGURAR_PARA_CONFIGURAR_MS:
			_segurado_desde.clear()
			get_tree().change_scene_to_file.call_deferred(CENA_CONFIGURACAO)
			return
