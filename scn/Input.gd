extends Node
class_name InputHandler

##! KeyBoard input and Smartphone input are supported

@onready var timer = $Timer as Timer

signal move(dir : Vector2i)
func _ready(): set_process_input(true)

func _input(event):
	if event is InputEventKey:
		if not event.pressed: return
			
		match event.keycode:
			KEY_LEFT:  move.emit(Vector2i.LEFT)
			KEY_RIGHT: move.emit(Vector2i.RIGHT)
			KEY_DOWN: move.emit( Vector2i.DOWN)
			KEY_UP:   move.emit( Vector2i.UP)
	if event is InputEventSingleScreenSwipe:
		var dir = event.relative.floor()
#		dir
		if abs(dir.x) >= abs(dir.y):
			dir = Vector2i(sign(dir.x), 0)
		else :
			dir = Vector2i(0, sign(dir.y))
			
		move.emit(dir)
		
	if event is InputEventSingleScreenTouch:
		if not event.pressed: return
		var pos : Vector2 = event.position
		var zero = get_viewport().get_visible_rect().size / 2
		pos = pos - zero
		if abs(pos.x) >= abs(pos.y):
			pos = Vector2i(sign(pos.x), 0)
		else:
			pos = Vector2i(0, sign(pos.y))
		move.emit(pos)
	
