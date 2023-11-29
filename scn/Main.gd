extends Node

@onready var board = $Board as Board
@onready var board_anim = $BoardAnim as BoardAnim
@onready var input := $Input as InputHandler
@onready var score := $Score as Score 
@onready var wheel := $Wheel as Wheel


func _ready():
	$Timer.timeout.connect(_on_check_can_play)
	
	board_anim.board_size = board.board_size

	board.block_moved.connect(   board_anim._on_block_moved   )
	board.block_fused.connect(   board_anim._on_block_fused   )
	board.block_created.connect( board_anim._on_block_created )

	input.move.connect( _on_move )

	board.block_fused.connect( func(_x, _y , level): score._on_level_appear(level) )

	board.block_created.connect( func(_x,level):     wheel._on_level_appear(level)   )
	board.block_fused.connect(   func(_x, _y , level): wheel._on_level_appear(level) )
	
	board.random_populate()
	
func _on_move(dir : Vector2i):
	if board.is_move_valid(dir):
		board._on_move(dir)
		board.random_populate()
		$Timer.start()
	# TODO check defeat

func _on_check_can_play():
	if board.no_move_left():
		print("game over!!!")
		# todo real game over and animations
		get_tree().create_timer(3.5).timeout.connect(func(): get_tree().change_scene_to_file("res://scn/Main.tscn"))
		
