class_name KeyDoor extends CollisionShape2D

@onready var parent_node = get_parent()

func _ready():
	if parent_node.has_signal("body_entered"):
		# Utiliza um Callable para referenciar a função _on_body_entered
		parent_node.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("O nó pai não possui o sinal 'body_entered'!")

func _on_body_entered(body):
	if body is CharacterBody2D and body is KeyItem:
		var _temp = body
		body.queue_free()
		add_to_group("KeyDoor")
		print("open teh door")
		parent_node.disconnect("body_entered", Callable(self, "_on_body_entered"))

func opendoor():
	if is_in_group("KeyDoor"):
		var temp = $Door/Locked
		var sprite = $Door/Sprite
		temp.disabled = true
		sprite.visible = false

func _process(delta: float) -> void:
	delta = delta
	opendoor()
