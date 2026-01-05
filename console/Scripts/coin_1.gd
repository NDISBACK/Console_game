extends Area2D
@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer





func _on_body_entered(body):
	game_manager.addPoint()
	animation_player.play("new_animation")
	
	 # Replace with function body.
