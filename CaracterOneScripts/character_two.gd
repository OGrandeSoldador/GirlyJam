extends CharacterBody2D

var player_name = "Max"

#gravity
@export var gravity: float = 800.0
@export var normal_gravity_multiplier: float = 1.0   # Multiplicador padrão da gravidade
@export var gravity_increase_rate: float = 1      # Taxa (por segundo) de aumento do multiplicador
@export var max_gravity_multiplier: float = 3.0      # Limite máximo do multiplicador

var current_gravity_multiplier: float = normal_gravity_multiplier
#Jump
@export var max_jump_velocity: float = -100.0
@export var jump_acceleration: float = -400.0       
@export var jump_velocity: float = -400.0
@export var speed: float = 350.0
@export var acceleration: float = 700.0
@export var friction: float = 1600.0

var jump_active: bool = false

#Magnetics
@export var is_magnetism_active: bool = false
@export var force_strength: float = 2
@export var magnetism_range: float = 300.0
@export var is_attracting: bool = true 

#intensity
#@export var max_intensity = 2.0 
#@export var min_intensity = 0.1  
#@export var n = 2.0  

func _ready():
	add_to_group("magnetizable")
	add_to_group("positive")

func inputs_atract_refuse():
		if Input.is_action_pressed("p2_magnetic_atract") or Input.is_action_pressed("p2_magnetic_repuse"):
			is_magnetism_active = true
		if Input.is_action_just_released("p2_magnetic_atract") or Input.is_action_just_released("p2_magnetic_repuse"):
			is_magnetism_active = false
		if Input.is_action_just_pressed("p2_change_polo"):
			is_attracting = !is_attracting
			print("change polo", is_attracting)

func _process(delta: float) -> void:
	delta = delta
	inputs_atract_refuse()

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	velocity.y += gravity * delta
	
	#if is_magnetism_active:
		#calc_magnetic_distance(delta)
	
	if is_on_floor():
		current_gravity_multiplier = normal_gravity_multiplier
	
	if is_on_floor() and Input.is_action_just_pressed("p2_jump"):
		velocity.y = jump_velocity  # Define a velocidade inicial do pulo
		jump_active = true          # Permite prolongar o pulo enquanto o botão estiver pressionado

# Se o pulo estiver ativo (ou seja, o jogador ainda pode prolongar o pulo)
	if jump_active:
		if Input.is_action_pressed("p2_jump"):
			if velocity.y > max_jump_velocity:
				velocity.y += jump_acceleration * delta
				if velocity.y < max_jump_velocity:
					velocity.y = max_jump_velocity
		else:
			# Ao soltar o botão, interrompe o prolongamento do pulo
			jump_active = false


# Aplica a gravidade com o multiplicador atual
	velocity.y += gravity * current_gravity_multiplier * delta
	
	# Movimento horizontal com aceleração
	var target_speed = 0
	if Input.is_action_pressed("p2_right"):
		target_speed = speed
	elif Input.is_action_pressed("p2_left"):
		target_speed = -speed
	
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	
	# Aplica atrito quando não há entrada de movimento
	if target_speed == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Pular se estiver no chão
	if is_on_floor() and Input.is_action_just_pressed("p2_jump"):
		velocity.y = jump_velocity

	if not is_on_floor():
		if velocity.y < 0:  # ADICIONADO: Verifica se o personagem ainda está subindo
			current_gravity_multiplier = min(current_gravity_multiplier + gravity_increase_rate * delta, max_gravity_multiplier)
	# Caso contrário, se já estiver descendo, o multiplicador permanece inalterado.

	# Move o personagem e trata colisões
	move_and_slide()

func calc_magnetic_distance(delta):
	var objects = get_tree().get_nodes_in_group("magnetizable")
	for obj in objects:
		if obj == self:
			continue  # Ignora a si mesmo
		var distance = position.distance_to(obj.position)
			
		if distance <= magnetism_range and distance > 0:
			#print("Aplicando força em:", obj.name, " | Distância:", distance)
			#print("DEBUG:", obj.name, "| Direção Normalizada:", direction)
			var intencity = calculate_magnetic_intensity(distance)
			apply_force_to_object(obj,intencity, delta)

func calculate_magnetic_intensity(distance):
	# Calcula a distância (magnitude) entre os dois pontos usando o vetor
	if distance > 0:
	# Calcula a intensidade da força magnética pela Lei do Inverso dos Quadrados
		distance = distance / 10000
		var intensity = 1.0 / (distance * distance)
		#print("| Distância:", distance, "| Intensidade:", intensity)
		return intensity

func apply_force_to_object(obj, intensity, delta):
	var direction = (obj.position - position).normalized()
	
	# Calcula a força final
	var force = (direction / 3) * intensity * force_strength
	print("DEBUG:", obj.name, "| Força Aplicada:", force)

	# Se for um CharacterBody2D
	if obj is CharacterBody2D:
		var _acceleration = force * delta  # Transformamos a força em aceleração
		
		# Diferencia o efeito no chão e no ar
		if obj.is_on_floor():
			_acceleration *= 0.3  # Reduz efeito no chão (atrito)
		else:
			acceleration *= 1.2  # Aumenta efeito no ar
		
		obj.velocity -= _acceleration + Vector2(0, gravity * delta) # Aplica a aceleração à velocidade do objeto
		obj.move_and_slide()
		print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)

	# Se for um RigidBody2D
	elif obj is RigidBody2D:
		obj.apply_impulse(Vector2.ZERO, force)
		print("DEBUG: Impulso aplicado ao RigidBody2D:", force)
