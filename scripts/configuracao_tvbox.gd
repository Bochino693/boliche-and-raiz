extends Control

const MENU := "res://scene/Main Menu.tscn"
var estado: Label
var ultimo_botao: String = "-"


func _ready() -> void:
	Tela.cobrir(self)
	var fundo := ColorRect.new()
	fundo.color = Color(0.015, 0.025, 0.045)
	Tela.cobrir_auto(fundo)
	add_child(fundo)

	var titulo := Label.new()
	titulo.text = "DRAGON BOWLING  |  CONFIGURACAO"
	titulo.position = Vector2(80, 210)
	titulo.add_theme_font_size_override("font_size", 42)
	add_child(titulo)

	estado = Label.new()
	estado.position = Vector2(80, 340)
	estado.size = Vector2(900, 750)
	estado.add_theme_font_size_override("font_size", 29)
	add_child(estado)
	_atualizar()


func _atualizar() -> void:
	estado.text = "MODO LIVRE | ULTIMO BOTAO USB: %s\n\nL3: voltar ao menu\nJogadas: QUADRADO / X / BOLINHA / TRIANGULO / R1" % ultimo_botao


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		ultimo_botao = str(event.button_index)
		_atualizar()
	if ArcadeControls.eh_config(event):
		get_tree().change_scene_to_file(MENU)
		get_viewport().set_input_as_handled()
