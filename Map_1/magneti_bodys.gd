class_name MagneticsBodys extends StaticBody2D

var group = "magnetizable"

func _ready() -> void:
	add_all_children_to_group(group)
	var child = get_child(0)
	child.add_to_group("positive")

func add_all_children_to_group(group_name: String):
	for child in get_children():
		child.add_to_group(group_name)
		# Só continua a recursão se o nó tiver filhos
		if child.get_child_count() > 0:
			add_all_children_to_group(group_name)
