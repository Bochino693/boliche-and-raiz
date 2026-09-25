extends Node2D

@onready var label = $CanvasLayer/LabelStart
var tempo := 0.0

func _ready():
	label.text = "PRESSIONE START PARA COMEÇAR"
	label.position = Vector2(200, 200)
	label.z_index = 10
	label.visible = true
	print(label)


func _process(_delta: float) -> void:
	# Faz o texto piscar
	tempo += _delta
	if int(tempo * 2) % 2 == 0:
		label.visible = true
	else:
		label.visible = false

	# Detecta tecla "1"
	if Input.is_action_just_pressed("ui_start"):
		get_tree().change_scene_to_file("res://scene/game.tscn")
