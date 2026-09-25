extends Control

const TECLAS_SENSORES: Array[String] = ["Z", "X", "C", "V", "B"]
const CENA_MENU_PRINCIPAL: String = "res://scene/Main Menu.tscn"

const ACOES_SENSORES: Dictionary = {
	"input_z": "Z",
	"input_x": "X",
	"input_c": "C",
	"input_v": "V",
	"input_b": "B"
}

const ACAO_START: String = "input_start"
const ACAO_SAIR_TESTE: String = "input_teste"
const NOME_START: String = "START"

var botoes: Dictionary = {}
var luzes: Dictionary = {}
var estados: Dictionary = {}
var labels_status: Dictionary = {}
var label_status_geral: Label
var painel_principal: PanelContainer


func _ready() -> void:
	_configurar_tela()
	_inicializar_dados()
	_criar_interface()

	set_process_input(true)
	set_process_unhandled_key_input(true)
	grab_focus()
	call_deferred("grab_focus")

	for tecla: String in TECLAS_SENSORES:
		_set_sensor(tecla, false)

	_set_sensor(NOME_START, false)
	visible = true


func _configurar_tela() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0

	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL


func _inicializar_dados() -> void:
	for tecla: String in TECLAS_SENSORES:
		estados[tecla] = false

	estados[NOME_START] = false


func _voltar_para_menu() -> void:
	if not ResourceLoader.exists(CENA_MENU_PRINCIPAL):
		push_error("Cena do menu não encontrada: " + CENA_MENU_PRINCIPAL)
		return

	get_viewport().set_input_as_handled()
	call_deferred("_executar_volta_menu")


func _executar_volta_menu() -> void:
	get_tree().change_scene_to_file(CENA_MENU_PRINCIPAL)


func _criar_interface() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0.03, 0.04, 0.06, 0.97)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var brilho_topo := ColorRect.new()
	brilho_topo.anchor_left = 0.0
	brilho_topo.anchor_top = 0.0
	brilho_topo.anchor_right = 1.0
	brilho_topo.anchor_bottom = 0.0
	brilho_topo.offset_bottom = 120.0
	brilho_topo.color = Color(0.20, 0.45, 0.95, 0.06)
	add_child(brilho_topo)

	painel_principal = PanelContainer.new()
	painel_principal.anchor_left = 0.5
	painel_principal.anchor_top = 0.5
	painel_principal.anchor_right = 0.5
	painel_principal.anchor_bottom = 0.5
	painel_principal.offset_left = -450.0
	painel_principal.offset_top = -690.0
	painel_principal.offset_right = 450.0
	painel_principal.offset_bottom = 690.0
	add_child(painel_principal)

	var estilo_painel := StyleBoxFlat.new()
	estilo_painel.bg_color = Color(0.08, 0.10, 0.14, 0.97)
	estilo_painel.border_width_left = 2
	estilo_painel.border_width_top = 2
	estilo_painel.border_width_right = 2
	estilo_painel.border_width_bottom = 2
	estilo_painel.border_color = Color(0.28, 0.42, 0.70, 0.55)
	estilo_painel.corner_radius_top_left = 24
	estilo_painel.corner_radius_top_right = 24
	estilo_painel.corner_radius_bottom_left = 24
	estilo_painel.corner_radius_bottom_right = 24
	estilo_painel.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	estilo_painel.shadow_size = 18
	painel_principal.add_theme_stylebox_override("panel", estilo_painel)

	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 18)
	margem.add_theme_constant_override("margin_top", 18)
	margem.add_theme_constant_override("margin_right", 18)
	margem.add_theme_constant_override("margin_bottom", 8)
	painel_principal.add_child(margem)

	var raiz := VBoxContainer.new()
	raiz.size_flags_vertical = Control.SIZE_EXPAND_FILL
	raiz.add_theme_constant_override("separation", 12)
	margem.add_child(raiz)

	var titulo := Label.new()
	titulo.text = "PAINEL DE TESTE"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.custom_minimum_size = Vector2(0, 44)
	titulo.add_theme_font_size_override("font_size", 26)
	titulo.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	titulo.add_theme_color_override("font_outline_color", Color(0.05, 0.10, 0.20, 1.0))
	titulo.add_theme_constant_override("outline_size", 4)
	raiz.add_child(titulo)

	label_status_geral = Label.new()
	label_status_geral.text = "AGUARDANDO INTERAÇÃO"
	label_status_geral.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_status_geral.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_status_geral.custom_minimum_size = Vector2(0, 34)
	label_status_geral.add_theme_font_size_override("font_size", 18)
	label_status_geral.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 1.0))
	raiz.add_child(label_status_geral)

	var sep1 := HSeparator.new()
	var sep1_style := StyleBoxFlat.new()
	sep1_style.bg_color = Color(0.28, 0.42, 0.70, 0.30)
	sep1_style.content_margin_top = 1
	sep1_style.content_margin_bottom = 1
	sep1.add_theme_stylebox_override("separator", sep1_style)
	raiz.add_child(sep1)

	var centro_start := CenterContainer.new()
	centro_start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raiz.add_child(centro_start)

	var card_start := _criar_card_sensor("Botão START", "input_start", NOME_START, true)
	centro_start.add_child(card_start)

	var sep2 := HSeparator.new()
	var sep2_style := StyleBoxFlat.new()
	sep2_style.bg_color = Color(0.28, 0.42, 0.70, 0.30)
	sep2_style.content_margin_top = 1
	sep2_style.content_margin_bottom = 1
	sep2.add_theme_stylebox_override("separator", sep2_style)
	raiz.add_child(sep2)

	var espacador_superior := Control.new()
	espacador_superior.size_flags_vertical = Control.SIZE_EXPAND_FILL
	raiz.add_child(espacador_superior)
	var espacador_fixo_rodape := Control.new()
	espacador_fixo_rodape.custom_minimum_size = Vector2(0, 90)
	raiz.add_child(espacador_fixo_rodape)

	var label_sensores := Label.new()
	label_sensores.text = "SENSORES"
	label_sensores.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_sensores.add_theme_font_size_override("font_size", 13)
	label_sensores.add_theme_color_override("font_color", Color(0.55, 0.68, 0.88, 1.0))
	raiz.add_child(label_sensores)

	var fileira := HBoxContainer.new()
	fileira.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fileira.add_theme_constant_override("separation", 8)
	raiz.add_child(fileira)

	var itens_sensores: Array = [
		{"titulo": "Z", "subtitulo": "Sensor 1", "chave": "Z"},
		{"titulo": "X", "subtitulo": "Sensor 2", "chave": "X"},
		{"titulo": "C", "subtitulo": "Sensor 3", "chave": "C"},
		{"titulo": "V", "subtitulo": "Sensor 4", "chave": "V"},
		{"titulo": "B", "subtitulo": "Sensor 5", "chave": "B"},
	]

	for item in itens_sensores:
		var card := _criar_card_sensor(item["titulo"], item["subtitulo"], item["chave"], false)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fileira.add_child(card)

	var barra_botoes := PanelContainer.new()
	var estilo_barra := StyleBoxFlat.new()
	estilo_barra.bg_color = Color(0.10, 0.13, 0.18, 0.95)
	estilo_barra.border_width_left = 1
	estilo_barra.border_width_top = 1
	estilo_barra.border_width_right = 1
	estilo_barra.border_width_bottom = 1
	estilo_barra.border_color = Color(0.32, 0.45, 0.70, 0.35)
	estilo_barra.corner_radius_top_left = 12
	estilo_barra.corner_radius_top_right = 12
	estilo_barra.corner_radius_bottom_left = 12
	estilo_barra.corner_radius_bottom_right = 12
	barra_botoes.add_theme_stylebox_override("panel", estilo_barra)
	raiz.add_child(barra_botoes)

	var barra_margem := MarginContainer.new()
	barra_margem.add_theme_constant_override("margin_left", 10)
	barra_margem.add_theme_constant_override("margin_top", 10)
	barra_margem.add_theme_constant_override("margin_right", 10)
	barra_margem.add_theme_constant_override("margin_bottom", 10)
	barra_botoes.add_child(barra_margem)

	var fileira_botoes := HBoxContainer.new()
	fileira_botoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fileira_botoes.add_theme_constant_override("separation", 8)
	barra_margem.add_child(fileira_botoes)

	for tecla in TECLAS_SENSORES:
		if botoes.has(tecla):
			var botao_existente: Button = botoes[tecla]
			if botao_existente.get_parent() != null:
				botao_existente.get_parent().remove_child(botao_existente)
			botao_existente.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			botao_existente.custom_minimum_size = Vector2(0, 42)
			fileira_botoes.add_child(botao_existente)

	if botoes.has(NOME_START):
		var botao_start: Button = botoes[NOME_START]
		if botao_start.get_parent() != null:
			botao_start.get_parent().remove_child(botao_start)
		botao_start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao_start.custom_minimum_size = Vector2(0, 42)
		fileira_botoes.add_child(botao_start)

	var rodape_box := PanelContainer.new()
	var estilo_rodape := StyleBoxFlat.new()
	estilo_rodape.bg_color = Color(0.10, 0.13, 0.18, 0.95)
	estilo_rodape.border_width_left = 1
	estilo_rodape.border_width_top = 1
	estilo_rodape.border_width_right = 1
	estilo_rodape.border_width_bottom = 1
	estilo_rodape.border_color = Color(0.32, 0.45, 0.70, 0.35)
	estilo_rodape.corner_radius_top_left = 12
	estilo_rodape.corner_radius_top_right = 12
	estilo_rodape.corner_radius_bottom_left = 12
	estilo_rodape.corner_radius_bottom_right = 12
	rodape_box.add_theme_stylebox_override("panel", estilo_rodape)
	raiz.add_child(rodape_box)

	var rodape_margem := MarginContainer.new()
	rodape_margem.add_theme_constant_override("margin_left", 10)
	rodape_margem.add_theme_constant_override("margin_top", 8)
	rodape_margem.add_theme_constant_override("margin_right", 10)
	rodape_margem.add_theme_constant_override("margin_bottom", 8)
	rodape_box.add_child(rodape_margem)

	var rodape := Label.new()
	rodape.text = "Z/X/C/V/B = sensores  •  input_start = START  •  input_teste = Menu Principal"
	rodape.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rodape.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rodape.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rodape.add_theme_font_size_override("font_size", 13)
	rodape.add_theme_color_override("font_color", Color(0.84, 0.90, 1.0, 1.0))
	rodape_margem.add_child(rodape)


func _criar_card_sensor(titulo_texto: String, subtitulo_texto: String, chave: String, is_start: bool) -> PanelContainer:
	var card := PanelContainer.new()

	if is_start:
		card.custom_minimum_size = Vector2(200, 150)
	else:
		card.custom_minimum_size = Vector2(0, 140)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.13, 0.18, 1.0)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.26, 0.30, 0.40, 1.0)
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
	card_style.shadow_size = 6
	card.add_theme_stylebox_override("panel", card_style)

	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 10)
	margem.add_theme_constant_override("margin_top", 10)
	margem.add_theme_constant_override("margin_right", 10)
	margem.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margem)

	var conteudo := VBoxContainer.new()
	conteudo.alignment = BoxContainer.ALIGNMENT_CENTER
	conteudo.add_theme_constant_override("separation", 5)
	margem.add_child(conteudo)

	var centro_luz := CenterContainer.new()
	conteudo.add_child(centro_luz)

	var luz := Panel.new()
	luz.custom_minimum_size = Vector2(48, 48) if not is_start else Vector2(56, 56)
	centro_luz.add_child(luz)
	luzes[chave] = luz

	var nome := Label.new()
	nome.text = titulo_texto
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nome.add_theme_font_size_override("font_size", 20 if not is_start else 22)
	nome.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	conteudo.add_child(nome)

	var tecla_label := Label.new()
	tecla_label.text = subtitulo_texto
	tecla_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tecla_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tecla_label.add_theme_font_size_override("font_size", 12)
	tecla_label.add_theme_color_override("font_color", Color(0.60, 0.72, 0.90, 1.0))
	conteudo.add_child(tecla_label)

	var status_sensor := Label.new()
	status_sensor.text = "OFF"
	status_sensor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_sensor.add_theme_font_size_override("font_size", 15)
	status_sensor.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))
	conteudo.add_child(status_sensor)
	labels_status[chave] = status_sensor

	var botao := Button.new()
	botao.text = "ATIVAR"
	botao.custom_minimum_size = Vector2(0, 34)
	botao.focus_mode = Control.FOCUS_NONE
	botao.add_theme_font_size_override("font_size", 13)
	botoes[chave] = botao

	var chave_local: String = chave

	botao.button_down.connect(func() -> void:
		_set_sensor(chave_local, true)
	)

	botao.button_up.connect(func() -> void:
		_set_sensor(chave_local, false)
	)

	return card


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(ACAO_SAIR_TESTE):
		_voltar_para_menu()
		return

	for acao: String in ACOES_SENSORES.keys():
		var sensor: String = ACOES_SENSORES[acao]

		if event.is_action_pressed(acao):
			_set_sensor(sensor, true)
			return

		if event.is_action_released(acao):
			_set_sensor(sensor, false)
			return

	if event.is_action_pressed(ACAO_START):
		_set_sensor(NOME_START, true)
		return

	if event.is_action_released(ACAO_START):
		_set_sensor(NOME_START, false)
		return


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACAO_SAIR_TESTE):
		_voltar_para_menu()


func _set_sensor(sensor: String, ativo: bool) -> void:
	if not luzes.has(sensor):
		return

	estados[sensor] = ativo

	var luz: Panel = luzes[sensor]

	var estilo := StyleBoxFlat.new()
	estilo.corner_radius_top_left = 40
	estilo.corner_radius_top_right = 40
	estilo.corner_radius_bottom_left = 40
	estilo.corner_radius_bottom_right = 40
	estilo.border_width_left = 3
	estilo.border_width_top = 3
	estilo.border_width_right = 3
	estilo.border_width_bottom = 3

	if ativo:
		if sensor == NOME_START:
			estilo.bg_color = Color(0.18, 0.72, 1.0, 1.0)
			estilo.border_color = Color(0.84, 0.95, 1.0, 1.0)
			estilo.shadow_color = Color(0.18, 0.72, 1.0, 0.60)
		else:
			estilo.bg_color = Color(0.00, 1.00, 0.35, 1.0)
			estilo.border_color = Color(0.84, 1.00, 0.92, 1.0)
			estilo.shadow_color = Color(0.00, 1.00, 0.35, 0.55)

		estilo.shadow_size = 16
	else:
		estilo.bg_color = Color(0.22, 0.22, 0.25, 1.0)
		estilo.border_color = Color(0.40, 0.40, 0.46, 1.0)
		estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
		estilo.shadow_size = 0

	luz.add_theme_stylebox_override("panel", estilo)

	if botoes.has(sensor):
		var botao: Button = botoes[sensor]
		botao.text = "ATIVO" if ativo else "ATIVAR"

	if labels_status.has(sensor):
		var label_individual: Label = labels_status[sensor]
		label_individual.text = "ON" if ativo else "OFF"

	if label_status_geral != null:
		if ativo:
			if sensor == NOME_START:
				label_status_geral.text = "BOTÃO START ATIVO"
			else:
				label_status_geral.text = "SENSOR %s ATIVO" % sensor
		else:
			var algum_ativo := false
			for chave in estados.keys():
				if estados[chave]:
					algum_ativo = true
					break

			if not algum_ativo:
				label_status_geral.text = "AGUARDANDO INTERAÇÃO"
