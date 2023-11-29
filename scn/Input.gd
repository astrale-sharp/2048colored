extends Node
class_name InputHandler
@onready var timer = $Timer as Timer

signal move(dir : Vector2i)
	
func _input(event):
	if event is InputEventKey:
		if (get_child(0) as Timer).is_stopped():
			(get_child(0) as Timer).start()
		else:
			return
		match event.keycode:
			KEY_LEFT:  move.emit(Vector2i.LEFT)
			KEY_RIGHT: move.emit(Vector2i.RIGHT)
			KEY_DOWN: move.emit(Vector2i.DOWN)
			KEY_UP:   move.emit(Vector2i.UP)
