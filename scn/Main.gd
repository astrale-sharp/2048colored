extends Node

@onready var board = $Board as Board
@onready var board_anim = $BoardAnim as BoardAnim
@onready var input := $Input as InputHandler
@onready var score := $Score as Score 
@onready var wheel := $Wheel as Wheel


func _ready():
	### SELF INIT
	$Timer.timeout.connect(_on_check_can_play)
	board_anim.board_size = board.board_size
	
	
	### LAYOUT
	var screen_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)
	
	var cell_size = 0.1 * screen_size.x #if OS.get_name() == "Android" else 64.0
	var board_anim_size = board.board_size * cell_size + board_anim.gap.x
	
	board_anim.cell_size = cell_size
	
	board_anim.position.x = screen_size.x / 2 - board_anim_size / 2
	board_anim.position.y = screen_size.y * 0.1
	
	wheel.position.x = screen_size.x * 0.05
	wheel.position.y = board_anim.position.y + board_anim_size + screen_size.y * 0.05
	### SIGNAL CONNECTION
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
		
