class_name ExitDoor extends CollisionShape2D

func _ready():
	var parent_node = get_parent()
	if parent_node.has_signal("body_entered"):
		# Utiliza um Callable para referenciar a função _on_body_entered
		parent_node.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("O nó pai não possui o sinal 'body_entered'!")

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.add_to_group("exit")
		print("Personagem adicionado ao grupo 'exit'")
