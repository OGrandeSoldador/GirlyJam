class_name Player extends CharacterBody2D

var player_name = "Max"
var player = 0

#Animation
var current_animation: AnimatedSprite2D
var animation_positive: AnimatedSprite2D
var animation_negative: AnimatedSprite2D

var last_animation = ""  # Armazena a última animação exibida

#gravity
@export var gravity: float = 900.0
@export var normal_gravity_multiplier: float = 1.0   # Multiplicador padrão da gravidade
@export var gravity_increase_rate: float = 1      # Taxa (por segundo) de aumento do multiplicador
@export var max_gravity_multiplier: float = 3.0      # Limite máximo do multiplicador

var current_gravity_multiplier: float = normal_gravity_multiplier

#Jump
@export var max_jump_velocity: float = -100.0
@export var jump_acceleration: float = -200.0       
@export var jump_velocity: float = -400.0
@export var speed: float = 400.0
@export var acceleration: float = 800.0
@export var friction: float = 1400.0

var jump_active: bool = false

#Magnetics
@export var is_magnetism_active: bool = false
@export var force_strength: float = 2
@export var magnetism_range: float = 350.0
@export var is_attracting: bool = true 

#intensity
@export var force_factor = 3 
@export var max_intensity = 5000
@export var min_intensity = 400 
@export var max_intensity_atract_player = 5000
@export var max_intensity_repuse_player = 10000
@export var min_intensity_atract_player = 500
@export var min_intensity_repuse_player = 500
@export var max_intensity_atract_staticbody = 2000
@export var max_intensity_repuse_staticbody = 2000
@export var min_intensity_atract_staticbody = 500
@export var min_intensity_repuse_staticbody = 500
@export var max_intensity_atract_itens = 5000
@export var max_intensity_repuse_itens = 5000
@export var min_intensity_atract_itens = 500
@export var min_intensity_repuse_itens = 500


#aceleration by magnetic
@export var on_floor_friction = 0.8
@export var on_air_friction = 1.0

var left = "p1_left"
var right = "p1_right"
var jump = "p1_jump"
var atract = "p1_magnetic_atract"
var repuse = "p1_magnetic_repuse"
var polo = "p1_change_polo"

var change_group_ax
const group = "magnetizable"
const positive_group = "positive"
const negative_group = "negative"
const disable_group = "disabled"
const itens = "keys"
var sigh = 1

func _ready():
	add_to_group(group)
	instanciate_animations()

func instanciate_animations():
	if player == 1:
		var anim = preload("res://Scenes/positiveMaxAnim.tscn")
		var anim2 = preload("res://Scenes/negativeMaxAnim.tscn")
		animation_positive = anim.instantiate()
		animation_negative = anim2.instantiate()
		current_animation = animation_positive
		add_child(animation_positive)
		add_child(animation_negative)
		print(animation_positive)
	if player == 2:
		var anim = preload("res://Scenes/positiveSamuelAnim.tscn")
		var anim2 = preload("res://Scenes/negativeSamuelAnim.tscn")
		animation_positive = anim.instantiate()
		animation_negative = anim2.instantiate()
		current_animation = anim2.instantiate()
		add_child(animation_positive)
		add_child(animation_negative)
		print(animation_positive)
		animation_negative.flip_h = true
		animation_positive.flip_h = true

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
	apply_animation()

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
	var _new_animation = null
	if Input.is_action_pressed(right):
		target_speed = speed
		animation_negative.flip_h = false
		animation_positive.flip_h = false
		
	elif Input.is_action_pressed(left):
		target_speed = -speed
		animation_negative.flip_h = true
		animation_positive.flip_h = true
		
	
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
		
		if obj.is_in_group("keys"):
			var magnetic_range_item = 100
			magnetism_range = magnetic_range_item
		else:
			magnetism_range = 300
		
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
	#print("DEBUG:", obj.name, "| Força Aplicada:", force)
	
	var _acceleration = force * delta  # Transformamos a força em aceleração
	#print("a aceleração que vai ser aplicada: ", _acceleration)
		
		# Diferencia o efeito no chão e no ar

	# Se for um CharacterBody2D
	if obj is CharacterBody2D or KeyItem:
		
		if obj.is_on_floor():
			_acceleration *= on_floor_friction # Reduz efeito no chão (atrito)
		else:
			_acceleration *= on_air_friction  # Aumenta efeito no ar
			
		if obj.is_in_group(positive_group) and is_in_group(positive_group) or obj.is_in_group(negative_group) and is_in_group(negative_group):
			sigh = 1
			max_intensity = max_intensity_repuse_player
			min_intensity = min_intensity_repuse_player
			#print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)
		else: 
			sigh = -1 
			max_intensity = max_intensity_repuse_player
			min_intensity = min_intensity_atract_player
			#print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)
			
		obj.velocity = obj.velocity + (_acceleration) * sigh
		print("DEBUG: Nova velocidade de", obj.name, ":", obj.velocity)

	elif obj is CollisionShape2D:
		
		if is_on_floor():
			_acceleration *= on_floor_friction # Reduz efeito no chão (atrito)
		else:
			_acceleration *= on_air_friction  # Aumenta efeito no ar
		
		if obj.is_in_group(positive_group) and is_in_group(positive_group) or obj.is_in_group(negative_group) and is_in_group(negative_group):
			if !obj.is_in_group(disable_group):
				sigh = 1
				max_intensity = max_intensity_repuse_staticbody
				min_intensity = min_intensity_repuse_staticbody
				#print("DEBUG: Nova velocidade de", obj.name, ":", velocity, "if")
		else:
			if !obj.is_in_group(disable_group):
				sigh = -1 
				max_intensity = max_intensity_repuse_staticbody
				min_intensity = min_intensity_atract_staticbody
				#print("DEBUG: Nova velocidade de", obj.name, ":", velocity, " else")

		velocity = velocity + (_acceleration) * sigh

func apply_animation():
	if not current_animation:
		return  # Evita erro se não houver sprite no grupo
	if is_in_group("positive"):
		current_animation.visible = false
		current_animation = animation_positive
		current_animation.visible = true
	else:
		current_animation.visible = false
		current_animation = animation_negative
		current_animation.visible = true

	var velocity_x = velocity.x
	#print(velocity_x)

	# Inverter o sprite horizontalmente baseado no movimento
	if velocity_x < 0:
		current_animation.flip_h = true
	elif velocity_x > 0:
		current_animation.flip_h = false
	
	# Escolher animação com base na velocidade
	if abs(velocity_x) < 5 :
		current_animation.play("Stopped")
	elif abs(velocity_x) < 50:
		current_animation.play("Walking")
	elif abs(velocity_x) >= 400:
		current_animation.play("Running")
	#if is_on_wall() and !is_on_floor():
		#for i in range(get_slide_collision_count()):
			#var collision = get_slide_collision(i)
			#var normal = collision.get_normal()
			#if normal.x < 0 :
				#current_animation.play("OnRightWall")
			#if normal.x > 0 :
				#current_animation.play("OnLeftWall")
	if is_on_wall() and is_on_floor():
		current_animation.play("Stopped")
	if !is_on_floor() and velocity.y < 0 and abs(velocity.x) < 30:
		current_animation.play("OnAir")

	if current_animation.animation != last_animation:  # Só printa se mudar
		#print("Animação atual:", current_animation.animation)
		last_animation = current_animation.animation  # Atualiza o valor salvo
