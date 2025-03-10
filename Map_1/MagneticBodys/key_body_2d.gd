class_name MagneticsItens extends RigidBody2D

var group = "magnetizable"
var key_group = "key"

func _ready() -> void:
	add_to_group(group)
	add_to_group(key_group)
