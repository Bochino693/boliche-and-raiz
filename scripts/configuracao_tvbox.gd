extends Control

## CONFIGURAÇÃO DOS BOTÕES DA ZERO DELAY — um botão de cada vez, na
## sequência da máquina. O que for apertado aqui é gravado na TV Box e
## passa a valer no jogo inteiro (ArcadeControls).
##
## Só botões de joystick contam: controle remoto e teclado são ignorados.
## Se ninguém apertar nada por 20 segundos, volta ao menu sem mudar nada.

const MENU := "res://scene/Main Menu.tscn"
const FONTE := "res://fonts/painel_arcade.ttf"
const ESPERA_MAXIMA_MS := 20000

var _passo := 0
var _botoes := {}
var _nome_da_placa := ""
var _segurando := -1
var _ultimo_toque_ms := 0
var _terminado := false

var _titulo: Label
var _pedido: Label
var _dica: Label
var _linhas: Array[Label] = []
var _rodape: Label


func _ready() -> void:
	Tela.cobrir(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fonte: Font = load(FONTE) if ResourceLoader.exists(FONTE) else null

	var fundo := ColorRect.new()
	fundo.color = Color(0.015, 0.025, 0.05)
	Tela.cobrir_auto(fundo)
	add_child(fundo)

	_titulo = _rotulo(fonte, "CONFIGURAR BOTÕES DA PLACA", Vector2(0, 120), 44, Color(0.55, 0.92, 1.0))
	_pedido = _rotulo(fonte, "", Vector2(0, 260), 64, Color(1.0, 0.86, 0.2))
	_dica = _rotulo(fonte, "APERTE O BOTÃO DA MÁQUINA", Vector2(0, 360), 30, Color(1, 1, 1, 0.75))

	var y := 470.0
	for item: Array in ArcadeControls.SEQUENCIA:
		var linha := _rotulo(fonte, "", Vector2(0, y), 32, Color(1, 1, 1, 0.55))
		_linhas.append(linha)
		y += 78.0

	_rodape = _rotulo(fonte, "", Vector2(0, 1380), 24, Color(1, 1, 1, 0.5))
	_ultimo_toque_ms = Time.get_ticks_msec()
	_atualizar()


func _rotulo(fonte: Font, texto: String, pos: Vector2, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.size = Vector2(Tela.TAMANHO.x, tamanho * 1.6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if fonte != null:
		l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)
	add_child(l)
	return l


func _atualizar() -> void:
	var total := ArcadeControls.SEQUENCIA.size()
	if _passo < total:
		_pedido.text = str(ArcadeControls.SEQUENCIA[_passo][1])
	for i in total:
		var acao: String = ArcadeControls.SEQUENCIA[i][0]
		var nome: String = ArcadeControls.SEQUENCIA[i][1]
		var linha := _linhas[i]
		if _botoes.has(acao):
			linha.text = "✔  %s   →   BOTÃO %d" % [nome, int(_botoes[acao])]
			linha.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		elif i == _passo:
			linha.text = "▶  %s" % nome
			linha.add_theme_color_override("font_color", Color(1.0, 0.86, 0.2))
		else:
			linha.text = "%s   (atual: %d)" % [nome, ArcadeControls.indice_de(acao)]
			linha.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	var restante: int = max(0, int(ceil((ESPERA_MAXIMA_MS - (Time.get_ticks_msec() - _ultimo_toque_ms)) / 1000.0)))
	_rodape.text = "SEM TOQUE, VOLTA AO MENU SEM ALTERAR EM %d s" % restante


func _process(_delta: float) -> void:
	if _terminado:
		return
	if Time.get_ticks_msec() - _ultimo_toque_ms > ESPERA_MAXIMA_MS:
		_terminado = true
		get_tree().change_scene_to_file.call_deferred(MENU)
		return
	_atualizar()


func _input(event: InputEvent) -> void:
	# Nada do teclado nem do controle remoto chega ao jogo por aqui.
	get_viewport().set_input_as_handled()
	if _terminado or not (event is InputEventJoypadButton):
		return
	var nome := Input.get_joy_name(event.device)
	var baixo := nome.to_lower()
	for trecho: String in ArcadeControls.NAO_E_PLACA:
		if baixo.contains(trecho):
			return
	var indice: int = event.button_index
	if not event.pressed:
		if indice == _segurando:
			_segurando = -1
		return
	_ultimo_toque_ms = Time.get_ticks_msec()
	if _segurando >= 0:
		return
	if _nome_da_placa != "" and nome != _nome_da_placa:
		return
	if indice in _botoes.values():
		_dica.text = "ESTE BOTÃO JÁ FOI USADO — APERTE OUTRO"
		return
	_nome_da_placa = nome
	_segurando = indice
	var acao: String = ArcadeControls.SEQUENCIA[_passo][0]
	_botoes[acao] = indice
	_passo += 1
	_dica.text = "APERTE O BOTÃO DA MÁQUINA"
	_atualizar()
	if _passo >= ArcadeControls.SEQUENCIA.size():
		_concluir()


func _concluir() -> void:
	_terminado = true
	ArcadeControls.gravar(_botoes, _nome_da_placa)
	_pedido.text = "PRONTO!"
	_dica.text = "GRAVADO. PARA REFAZER: L3, OU SEGURE UM BOTÃO 5 s NO MENU"
	_rodape.text = _nome_da_placa
	await get_tree().create_timer(1.6).timeout
	get_tree().change_scene_to_file(MENU)
