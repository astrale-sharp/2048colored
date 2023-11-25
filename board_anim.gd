extends Control

const cell_size = 64
const gap = Vector2.ONE * 20
var board_size : int
var board = {}


func _ready():
	if owner == null:
		board_size = 5
		set_process_input(true)
	else:
		set_process_input(false)
		
	if not board_size: printerr("board_size not define")
	

# test only
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var p = (event.position - gap) / cell_size
			p = Vector2i(p)
			if Vector2i.ZERO <= p and p <= Vector2i.ONE * board_size:
				if board.get(p) == null:
					_on_block_created(p)
					


func _draw():
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE * board_size * cell_size + gap),Color.BLACK,false)


func _on_block_created(pos : Vector2i):
	pass

func _on_block_fused():
	pass
