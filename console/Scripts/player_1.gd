extends CharacterBody2D

const SPEED := 170.0
const JUMP_VELOCITY := -300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_zone: DamageZone = $deal_damage_zone
@onready var hitbox: Area2D = $hitbox
@onready var health_bar: ProgressBar = $"CanvasLayer/health bar"


var health_max := 100
var health := health_max
var dead := false
var current_attack := false
var knockback
var knockback_timer
var enemy_velocity
var camera_shake_value = 5

# INPUTS (change in Inspector for Player 2)
@export var input_left := "p1_left"
@export var input_right := "p1_right"
@export var input_jump := "p1_jump"
@export var input_attack1 := "p1_attack"
@export var input_attack2 := "p1_other"
@export var knockback_power = 500

# IMPORTANT: initial facing
@export var facing_right := true



func _ready():
	health = 100
	health_bar.init_health(health)
	damage_zone.owner_player = self
	damage_zone.get_node("CollisionShape2D").disabled = true

	# set initial facing (VERY IMPORTANT for Player 2)
	if facing_right:
		sprite.flip_h = false
		damage_zone.position.x = abs(damage_zone.position.x)
	else:
		sprite.flip_h = true
		damage_zone.position.x = -abs(damage_zone.position.x)


func _physics_process(delta):
	velocity.x = move_toward(velocity.x, 0, 1200 * delta)

	
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis(input_left, input_right)
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip + damage zone direction
	if direction > 0:
		sprite.flip_h = false
		damage_zone.position.x = abs(damage_zone.position.x)
	elif direction < 0:
		sprite.flip_h = true
		damage_zone.position.x = -abs(damage_zone.position.x)

	# ---------------- ATTACK INPUT (FIXED) ----------------
	if not current_attack:
		if Input.is_action_just_pressed(input_attack1):
			if not is_on_floor():
				start_attack("air")
				camera_shake_value = 15
			else:
				start_attack("punch")
				camera_shake_value = 5

		elif Input.is_action_just_pressed(input_attack2):
			if not is_on_floor():
				start_attack("air")
				camera_shake_value = 15
			else:
				start_attack("attack2")
				camera_shake_value = 5

	# Animations
	if not current_attack:
		if velocity.x == 0:
			sprite.play("default")
		else:
			sprite.play("walk")

	move_and_slide()


# ---------------- ATTACK SYSTEM ----------------

func start_attack(type: String):
	current_attack = true

	var attack_time: float

	match type:
		"punch":
			damage_zone.damage = 8
			attack_time = 0.35
			
		"attack2":
			damage_zone.damage = 8
			attack_time = 0.35
			
		"air":
			damage_zone.damage = 15
			attack_time = 0.5
			

	damage_zone.owner_player = self
	sprite.play(type + "_attack")
	enable_damage_zone(type)

	# ✅ Gameplay-controlled reset
	await get_tree().create_timer(attack_time).timeout
	current_attack = false


func enable_damage_zone(type: String):
	var wait_time := 0.3
	if type == "air":
		wait_time = 0.5

	var shape := damage_zone.get_node("CollisionShape2D")
	shape.disabled = false
	await get_tree().create_timer(wait_time).timeout
	shape.disabled = true


func _on_AnimatedSprite2D_animation_finished() -> void:
	current_attack = false


# ---------------- DAMAGE SYSTEM ----------------

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is DamageZone:
		var dz := area as DamageZone

		if dz.owner_player == self:
			return

		var attacker: CharacterBody2D = dz.owner_player
		take_damage(dz.damage, attacker.global_position)

		# 🔥 CAMERA SHAKE ON HIT
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("shake"):
			cam.shake(camera_shake_value)


		


func take_damage(amount: int, attacker_pos: Vector2) -> void:

	if dead:
		return
	
	var dir = 1
	if sprite.flip_h:
		dir = -1


	health -= amount
	
	
	health_bar.health = health
	print(name, " health:", health)

	if health <= 0:
		die()


func die():
	dead = true
	sprite.play("dead")
	await get_tree().create_timer(3).timeout
	queue_free()
	var win_screen := get_tree().current_scene.get_node("CanvasLayer/WinScreen")
	if win_screen:
		var winner := "PLAYER 1" if name == "Player2" else "PLAYER 2"
		win_screen.show_winner(winner)

	
func apply_knockback(attacker_pos: Vector2) -> void:
	var dir: float = sign(global_position.x - attacker_pos.x)

	velocity.x = dir * knockback_power
	velocity.y = -150   # small lift (optional)

	
