extends Node

const CENA_MENU = "res://scene/main_menu.tscn"

func _ready() -> void:
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.play_menu_music()

	call_deferred("_abrir_menu")


func _abrir_menu() -> void:
	get_tree().change_scene_to_file(CENA_MENU)
