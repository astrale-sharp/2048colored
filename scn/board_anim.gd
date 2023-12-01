@tool
extends Control
class_name BoardAnim

## It is assumed in _on_game_over_animation_start that the only children 
## of this node is the blocks


signal animation_finished
var block := preload("res://scn/block.tscn")

@export var board_size : int

var board = {} # Vector2 -> Block
var cell_size: float
const gap = Vector2.ONE * 20

func _ready():
	set_process_input(false)
	if not board_size: printerr("board_size not defined")
	### TEST ONLY
	return
	board_size = 5
	set_process_input(true)


func _draw():
	draw_rect(
		Rect2(Vector2.ZERO, Vector2.ONE * board_size * cell_size + gap),
		Color.BLACK,
		false,
	)


func _on_block_created(pos : Vector2i, level : int):
	var b := block.instantiate() as Block
	b.size = Vector2(cell_size, cell_size)
	b.level = level - 1
	b.position = (pos * cell_size as Vector2) + gap / 2
	board[pos] = b
	add_child(b)
	b.level_up()

func _on_block_moved(start : Vector2i, end : Vector2i):
	var b : Block = board[start]
	board.erase(start)
	b.move_to( (end * cell_size) as Vector2 + gap/2 )
	board[end] = b

func _on_block_fused(start : Vector2i, end: Vector2i, level):
	var sblock : Block = board[start]
	board.erase(start)
	sblock.move_to((end * cell_size) as Vector2 + gap/2)
	sblock.fade_out()
	(board[end] as Block).level_up()


func _on_game_over_animation_start():
	
	# counter to keep all the blocks accounted for before 
	# emiting animation_finished.
	# Why an Array? Hack to get local variable capture in gdscript
	var i = [get_child_count()]
	for c in get_children():
		c = c as Block
		c.animation_finished.connect(
			func (): 
				i[0] -= 1
				if i[0] == 0: animation_finished.emit()
		)
		c.game_over()


### TEST only
func _input(event):
	return
	if event is InputEventMouseButton:
		if event.pressed:
			var p = (event.position - gap/2) / cell_size
			p = Vector2i(p)
			if Vector2i.ZERO <= p and p <= Vector2i.ONE * board_size:
				if board.get(p) == null:
					_on_block_created(p, 0)

