extends Control

@onready var label: Label = $Label


func show_winner(player_name: String) -> void:
	visible = true
	label.text = player_name + " WINS!"
	get_tree().paused = false
	
	
func _ready() -> void:
	visible = false
	get_tree().paused = false


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
