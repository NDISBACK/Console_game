extends Control
@onready var play: Button = $VBoxContainer/play
@onready var quit: Button = $VBoxContainer/Quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Main menu loaded")
	get_tree().paused = false
	Engine.time_scale = 1.0
	print("Main menu loaded")




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://console/Scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
