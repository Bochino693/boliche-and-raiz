extends Node

## O Input Map do projeto define os botoes. Edite as acoes no Godot;
## nenhum mapeamento fixo em script substitui as escolhas do operador.

func eh_start(event: InputEvent) -> bool:
	return event.is_action_pressed("input_start") and not event.is_echo()


func eh_config(event: InputEvent) -> bool:
	return event.is_action_pressed("input_teste") and not event.is_echo()


func tecla_jogada(event: InputEvent) -> String:
	if event.is_echo():
		return ""
	for acao: String in ["input_z", "input_x", "input_c", "input_v", "input_b"]:
		if event.is_action_pressed(acao):
			match acao:
				"input_z": return "Z"
				"input_x": return "X"
				"input_c": return "C"
				"input_v": return "V"
				"input_b": return "B"
	return ""
