extends Camera2D

@export var player_1: Node2D
@export var player_2: Node2D

@export var min_zoom := Vector2(1.2, 1.2)
@export var max_zoom := Vector2(0.6, 0.6)
@export var max_distance := 600.0
@export var shake_fade: float = 20.0

var shake_strength: float = 0.0
var base_offset: Vector2

func _process(delta):
	if not player_1 or not player_2:
		return

	
	var center := (player_1.global_position + player_2.global_position) / 2
	global_position = global_position.lerp(center, delta * 5)

	var distance := player_1.global_position.distance_to(player_2.global_position)
	var t: float = clamp(distance / max_distance, 0.0, 1.0)

	zoom = min_zoom.lerp(max_zoom, t)
	if shake_strength > 0.0:
		shake_strength = max(shake_strength - shake_fade * delta, 0.0)

		offset = base_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = base_offset




func _ready() -> void:
	base_offset = offset

	

func shake(intensity: float) -> void:
	shake_strength = max(shake_strength, intensity)
