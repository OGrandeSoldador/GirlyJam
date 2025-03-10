extends Node2D

@onready var transition = $Transition

var player
var is_finished_map = false
var current_map = 0

var maps = {}

func preload_maps():
	maps[0] = preload("res://Scenes/Map1.tscn")
	maps[1] = preload("res://Scenes/Map2.tscn")
	print("Todos os mapas foram pré-carregados.")

func instantiate_map(map_number: int) -> Node:
	if map_number in maps:
		var new_map = maps[map_number].instantiate()
		add_child(new_map) # Adiciona à cena atual
		print("Mapa %d instanciado." % map_number)
		return new_map
	else:
		print("Erro: Mapa %d não encontrado." % map_number)
		return null

func wait_for_two_exits(is_finished):
	if is_finished == false:
		if get_tree().get_nodes_in_group("exit").size() < 2:
			var exit_count = get_tree().get_nodes_in_group("exit").size()
			if exit_count >= 1:
				player = get_tree().get_nodes_in_group("exit")[0]
				disable_player_input()
		if get_tree().get_nodes_in_group("exit").size() == 2:
			player = get_tree().get_nodes_in_group("exit")[1]
			disable_player_input()
			print(get_tree().get_nodes_in_group("exit"))
			current_map += current_map
			return true

func disable_player_input() -> void:
	if player:
		# Desabilita o processamento de input do player
		player.set_process_input(false)
		# Se o movimento ou outras lógicas estiverem em physics_process, desabilite também
		player.set_physics_process(false)

func transition_map():
	transition.visible = true
	transition.play("start")
	transition.animation_finished.connect(_on_finished_trasition)

func clear_old_map():
	for filho in get_children():
		if filho is StartMap:
			filho.queue_free()
		await get_tree().process_frame
	current_map = current_map + 1
	instantiate_map(current_map)

func _on_finished_trasition():
	clear_old_map()
	transition.disconnect("animation_finished", Callable (self, "_on_finished_trasition"))
	transition.play_backwards("start")
	transition.animation_finished.connect(_on_reverse_transition_finished)

func _on_reverse_transition_finished():
	transition.visible = false

func _process(delta: float) -> void:
	delta = delta
	if wait_for_two_exits(is_finished_map):
		is_finished_map = !is_finished_map
		if is_finished_map == true:
			transition_map()

func _ready() -> void:
	preload_maps()
	instantiate_map(current_map)
