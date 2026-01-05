extends ColorRect

@export var fade_speed: float = 20.0

func flash(color: Color = Color.WHITE, strength: float = 0.8) -> void:
	self.color = color
	visible = true
	modulate.a = strength

func _process(delta: float) -> void:
	if not visible:
		return

	modulate.a -= fade_speed * delta
	if modulate.a <= 0.0:
		visible = false
