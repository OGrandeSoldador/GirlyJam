class_name Player extends CharacterBody2D

#gravity
@export var gravity: float = 800.0
@export var normal_gravity_multiplier: float = 1.0   # Multiplicador padrão da gravidade
@export var gravity_increase_rate: float = 1      # Taxa (por segundo) de aumento do multiplicador
@export var max_gravity_multiplier: float = 3.0      # Limite máximo do multiplicador

var current_gravity_multiplier: float = normal_gravity_multiplier

#Jump
@export var max_jump_velocity: float = -500.0
@export var jump_acceleration: float = -700.0       
@export var jump_velocity: float = -500.0
@export var speed: float = 400.0
@export var acceleration: float = 800.0
@export var friction: float = 1400.0

var jump_active: bool = false

#Magnetics
@export var is_magnetism_active: bool = false
@export var force_strength: float = 2
@export var magnetism_range: float = 300.0
@export var is_attracting: bool = true 

#intensity
@export var max_intensity = 5000
@export var min_intensity = 400 
@export var force_factor = 3 
@export var max_intensity_atract = 5000
@export var max_intensity_repuse = 10000
@export var min_intensity_atract = 500
@export var min_intensity_repuse = 500


#aceleration by magnetic
@export var on_floor_friction = 0.8
@export var on_air_friction = 1.0

var left = "p1_left"
var right = "p1_right"
var jump = "p1_jump"
var atract = "p1_magnetic_atract"
var repuse = "p1_magnetic_repuse"
var polo = "p1_chance_polo"

var change_group_ax = true
var group = "magnetizable"
var positive_group = "positive"
var negative_group = "negative"
var sigh = 1

func _ready():
	add_to_group(group)

func inputs_atract_refuse():
		if Input.is_action_pressed(atract) or Input.is_action_pressed(repuse):
			is_magnetism_active = true
		if Input.is_action_just_released(atract) or Input.is_action_just_released(repuse):
			is_magnetism_active = false
		if Input.is_action_just_pressed(polo):
			if change_group_ax:
				add_to_group(positive_group)
				remove_from_group(negative_group)
				change_group_ax = !change_group_ax
				var groups = get_groups()
				print(groups)
			else:
				add_to_group(negative_group)
				remove_from_group(positive_group)
				change_group_ax = !change_group_ax
				var groups = get_groups()
				print(groups)

func _process(delta: float) -> void:
	delta = delta
	inputs_atract_refuse()

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	velocity.y += gravity * delta
	
	if is_magnetism_active:
		calc_magnetic_distance(delta)
	
	if is_on_floor():
		current_gravity_multiplier = normal_gravity_multiplier
	
	if is_on_floor() and Input.is_action_just_pressed(jump):
		velocity.y = jump_velocity  # Define a velocidade inicial do pulo
		jump_active = true          # Permite prolongar o pulo enquanto o botão estiver pressionado

# Se o pulo estiver ativo (ou seja, o jogador ainda pode prolongar o pulo)
	if jump_active:
		if Input.is_action_pressed(jump):
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
	if Input.is_action_pressed(right):
		target_speed = speed
	elif Input.is_action_pressed(left):
		target_speed = -speed
	
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	
	# Aplica atrito quando não há entrada de movimento
	if target_speed == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Pular se estiver no chão
	if is_on_floor() and Input.is_action_just_pressed(jump):
		velocity.y = jump_velocity

	if not is_on_floor():
		if velocity.y < 0:  # ADICIONADO: Verifica se o personagem ainda está subindo
			current_gravity_multiplier = min(current_gravity_multiplier + gravity_increase_rate * delta, max_gravity_multiplier)
	# Caso contrário, se já estiver descendo, o multiplicador permanece inalterado.

	# Move o personagem e trata colisões
	move_and_slide()

func calc_magnetic_distance(delta):
	var objects = get_tree().get_nodes_in_group(group)
	for obj in objects:
		if obj == self:
			continue  # Ignora a si mesmo
		var distance = position.distance_to(obj.position)
			
		if distance <= magnetism_range and distance > 0:
			#print("Aplicando força em:", obj.name, " | Distância:", distance)
			#print("DEBUG:", obj.name, "| Direção Normalizada:", direction)
			var intencity = calculate_magnetic_intensity(distance)
			apply_force_to_object(obj,distance,intencity, delta)

func calculate_magnetic_intensity(distance):
	# Calcula a distância (magnitude) entre os dois pontos usando o vetor
	if distance > 0:
	# Calcula a intensidade da força magnética pela Lei do Inverso dos Quadrados
		distance = distance / 10000
		var intensity = 1.0 / (distance * distance)
		#print("| Distância:", distance, "| Intensidade:", intensity)
		
		return clamp(intensity,min_intensity,max_intensity)

func apply_force_to_object(obj, _distance, intensity, delta):
	var direction = (obj.position - position).normalized()
	
	# Calcula a força final
	var force = (direction / force_factor) * intensity * force_strength
	print("DEBUG:", obj.name, "| Força Aplicada:", force)

	# Se for um CharacterBody2D
	if obj is CharacterBody2D:
		var _acceleration = force * delta  # Transformamos a força em aceleração
		print("a aceleração que vai ser aplicada: ", _acceleration)
		
		# Diferencia o efeito no chão e no ar
		if obj.is_on_floor():
			_acceleration *= on_floor_friction # Reduz efeito no chão (atrito)
		else:
			_acceleration *= on_air_friction  # Aumenta efeito no ar
		
		
		if obj.is_in_group(positive_group) and is_in_group(positive_group) or obj.is_in_group(negative_group) and is_in_group(negative_group):
			sigh = 1
			max_intensity = max_intensity_repuse
			min_intensity = min_intensity_repuse
			obj.velocity = obj.velocity + (_acceleration) * sigh
			print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)
		else: 
			sigh = -1 
			max_intensity = max_intensity_repuse
			min_intensity = min_intensity_atract
			obj.velocity = obj.velocity + (_acceleration) * sigh
			print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)
			
			
		#obj.velocity = obj.velocity + (_acceleration) * sigh
		#print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)

	# Se for um RigidBody2D
	elif obj is RigidBody2D:
		obj.apply_impulse(Vector2.ZERO, force)
		print("DEBUG: Impulso aplicado ao RigidBody2D:", force)
		
