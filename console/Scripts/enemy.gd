extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var takedamagecooldown: Timer = $takedamagecooldown
@onready var health_bar: ProgressBar = $"health bar"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var speed = 25
var player_chase = false
var player = null
var health = 130
var player_attack_range = false
var player_attack_cooldown = true
var take_damage = true
@onready var timer: Timer = $Timer
func _ready() -> void:
	health = 100
	health_bar.init_health(health)

func _physics_process(delta: float) -> void:
	deal_with_damage()
	
	if player_chase and player != null:
		# Movement logic
		position += (player.position - position) / speed
		
		# Directional Flip
		if (player.position.x - position.x) < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
			
		# ANIMATION LOGIC
		if player_attack_range:
			# Play attack ONLY if it's not already playing
			if animated_sprite_2d.animation != "attack":
				animated_sprite_2d.play("attack")
		else:
			# Play chase ONLY if it's not already playing
			if animated_sprite_2d.animation != "chase":
				animated_sprite_2d.play("chase")
	else:
		# If we aren't chasing, go back to default/idle
		if animated_sprite_2d.animation != "default":
			animated_sprite_2d.play("default")

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
	
	
func enemy():
	pass
	

		
	


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_attack_range = true
		
	
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_attack_range = false
		
	
	

func deal_with_damage():
	if player_attack_range and Global.player_current_attack == true:
		if take_damage == true:
			health -= 20
			audio_stream_player_2d.play()
			health_bar.health = health
			take_damage = false
			takedamagecooldown.start()
			print("enemy health ", health)
			if health <= 0:
				self.queue_free()

func _on_takedamagecooldown_timeout() -> void:
	take_damage = true
