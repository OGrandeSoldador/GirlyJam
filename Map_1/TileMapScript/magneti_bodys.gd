class_name StartMap extends StaticBody2D

@onready var player_scene = preload("res://Scenes/Character.tscn")
@export var player_start_position : Vector2 = Vector2(128, 540)

@onready var player_scene_2 = preload("res://Scenes/Character.tscn")
@export var player_start_pos : Vector2 = Vector2(1152,540)

func _ready():
	var player_1 = player_scene.instantiate()
	
	player_1.player_name = "Max"
	player_1.player = 1
	player_1.position = player_start_position
	player_1.add_to_group("positive")
	player_1.left = "p1_left"
	player_1.right = "p1_right"
	player_1.jump = "p1_jump"
	player_1.atract = "p1_magnetic_atract"
	player_1.polo = "p1_change_polo"
	add_child(player_1)
	
	var player_2 = player_scene.instantiate()
	
	player_2.player_name = "Samuel"
	player_2.player = 2
	player_2.position = player_start_pos
	player_2.add_to_group("negative")
	player_2.left = "p2_left"
	player_2.right = "p2_right"
	player_2.jump = "p2_jump"
	player_2.atract = "p2_magnetic_atract"
	player_2.polo = "p2_change_polo"
	add_child(player_2)
