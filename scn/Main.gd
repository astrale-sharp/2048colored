extends Node

##! Main script connecting all the nodes and handling the connection
##! between input logic and board logic
##!
##! Also handles some layouting logic


@onready var board = $Board as Board
@onready var board_anim = $BoardAnim as BoardAnim
@onready var input := $Input as InputHandler
@onready var score := $Score as Score 
@onready var wheel := $Wheel as Wheel

## On this signal being emitted, will wait to receive
## responsed in _on_game_over_animation_done
## When all answers are received, end game
signal game_over_animation_start

func _ready():
	### SELF INIT
	$Timer.timeout.connect(_on_check_can_play)
	board_anim.board_size = board.board_size
	
	
	### LAYOUT
	var board_anim_size = board.board_size * Constants.CELL_SIZE + board_anim.gap.x
	
	board_anim.cell_size = Constants.CELL_SIZE
	
	board_anim.position.x = Constants.SCREEN_SIZE.x / 2 - board_anim_size / 2
	board_anim.position.y = Constants.SCREEN_SIZE.y * 0.1

	wheel.position.x = Constants.SCREEN_SIZE.x/2 - wheel.total_width/2 - Constants.CELL_SIZE/ 2
	wheel.position.y = board_anim.position.y + board_anim_size + Constants.SCREEN_SIZE.y * 0.05

	### SIGNAL CONNECTION
	board.block_moved.connect(   board_anim._on_block_moved   )
	board.block_fused.connect(   board_anim._on_block_fused   )
	board.block_created.connect( board_anim._on_block_created )

	input.move.connect( _on_move )

	board.block_fused.connect( func(_x, _y , level): score._on_level_appear(level) )

	board.block_created.connect( func(_x,level):     wheel._on_level_appear(level)   )
	board.block_fused.connect(   func(_x, _y , level): wheel._on_level_appear(level) )

	### GAME OVER ANIMATION HANDLING
	
	# disconnect input	
	game_over_animation_start.connect( 
		func(): input.move.disconnect(input.move.get_connections().pop_back()["callable"]),
		CONNECT_ONE_SHOT,
	)
	
	
	game_over_animation_start.connect( wheel._on_game_over_animation_start     , CONNECT_ONE_SHOT )
	game_over_animation_start.connect( board_anim._on_game_over_animation_start, CONNECT_ONE_SHOT )
	
	wheel.animation_finished.connect(      func(): 
												wheel_anim_game_over_done = true; 
												_on_game_over_animation_done(),
											CONNECT_ONE_SHOT)
	board_anim.animation_finished.connect( func(): 
												board_anim_game_over_done = true; 
												_on_game_over_animation_done(),
											CONNECT_ONE_SHOT)
	### START GAME
	board.random_populate()
	
func _on_move(dir : Vector2i):
	if board.is_move_valid(dir):
		board._on_move(dir)
		board.random_populate()
		$Timer.start()

func _on_check_can_play():
	if board.no_move_left():
		game_over_animation_started = true
		await get_tree().create_timer(1.2).timeout
		game_over_animation_start.emit()
		# We then wait each animation to be finished in _on_game_over_animation_done()

var game_over_animation_started := false
var board_anim_game_over_done := false
var wheel_anim_game_over_done := false
func _on_game_over_animation_done():
	if board_anim_game_over_done and wheel_anim_game_over_done:
		# TODO, save a picture of the board? the high score
		get_tree().change_scene_to_file("res://scn/Main.tscn")


func _input(event):
	# skip game_over animation
	if game_over_animation_started:
		if event is InputEventSingleScreenLongPress\
			or event is InputEventMultiScreenLongPress\
			or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER) :
				get_tree().change_scene_to_file("res://scn/Main.tscn")
	
	### TEST only
	return
	if event is InputEventKey:
		if not event.pressed: return
		if event.keycode == KEY_G:
			game_over_animation_started = true
			game_over_animation_start.emit()
