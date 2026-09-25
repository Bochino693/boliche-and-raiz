class_name TransicaoFoto
extends CanvasLayer

## TROCA DE TELA SEM TELA DE CARREGAMENTO E SEM TELA CINZA.
##
## Na hora da troca, o último quadro da tela antiga vira uma foto que fica
## por cima de tudo. A cena nova monta por baixo (a pista, os pinos e os
## painéis entram com as animações de montagem dela) enquanto a foto
## cresce de leve e some. Nunca aparece um quadro vazio.

const DURACAO := 0.55

var _foto: Sprite2D


## Tira a foto do quadro atual e deixa ela por cima de tudo. Chame ANTES
## de trocar a cena; a foto se desfaz sozinha.
static func cobrir(arvore: SceneTree) -> void:
	var raiz := arvore.root
	var imagem := raiz.get_texture().get_image()
	if imagem == null or imagem.is_empty():
		return
	var camada := TransicaoFoto.new()
	camada._montar(ImageTexture.create_from_image(imagem), raiz)
	raiz.add_child(camada)


func _montar(textura: Texture2D, raiz: Window) -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	# A foto está em pixels da JANELA (já girada para o HDMI). Desfaz o giro
	# do Tela e a escala da janela para ela cair exatamente onde estava.
	transform = raiz.global_canvas_transform.affine_inverse()
	var logico := Vector2(raiz.content_scale_size)
	if logico.x <= 0.0 or logico.y <= 0.0:
		logico = Vector2(raiz.size)
	_foto = Sprite2D.new()
	_foto.texture = textura
	_foto.centered = true
	_foto.position = logico * 0.5
	_foto.scale = logico / textura.get_size()
	add_child(_foto)


func _ready() -> void:
	# O quadro em que a cena nova é montada é longo; a animação só começa
	# depois dele, senão pularia metade do caminho de uma vez.
	await get_tree().process_frame
	await get_tree().process_frame
	var base := _foto.scale
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_foto, "scale", base * 1.06, DURACAO)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(_foto, "modulate:a", 0.0, DURACAO)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.chain().tween_callback(queue_free)
