extends Node
class_name Board
##! This script deals with the board logic
##! and is capable of moving the blocks  with the logic from _on_move

@export var board_size = 4

## merge blocks more agressively
@export var recursive := true

signal block_moved(from : Vector2i, to : Vector2i)
signal block_fused(from : Vector2i, to : Vector2i, level_reached)
signal block_created( pos : Vector2i, level : int)

## reprensents
## board[x][y] = null | int
var board := {}

func _ready():
	## INIT SELF
	for x in range(board_size):
		board[x] = {}
		for y in range(board_size):
			board[x][y] = null

	### TEST ONLY
	return
	var t = Timer.new()
	t.wait_time = 0.7
	t.one_shot = true
	add_child(t)
	set_process_input(true)
	random_populate()
	pprint()

func _board_get(pos : Vector2i): # -> int | null
	return board[pos.x][pos.y]

func _get_available_tiles() -> Array:
	var res = []
	for x in range(board_size):
		for y in range(board_size):
			if board[x].get(y) == null:
				res.push_back(Vector2i(x,y))
	return res

## Adds one or two block of level 1 or (less likely) 2.
func random_populate():
	for k in randi_range(1,2):
		var pos = _get_available_tiles()
		pos = pos.pick_random() if pos != [] else null
		var level = 0 if randf() <= 0.75 else 1
		if pos is Vector2i:
			board[pos.x][pos.y] = level
			block_created.emit(pos, level)
		
## Core algorithm
## Abstract over the concept of line and column for each direction
func _on_move(direction : Vector2i):
	# position of the cell we're trying to move
	var pos : Vector2i
	# continue aling this line
	var line_step : Vector2i
	# the line is over
	var line_end_condition : Callable

	# the vector is is bounds
	var in_bounds := func(p : Vector2i): 
		return p.x <= board_size - 1 \
				and p.y <= board_size - 1 \
				and p.x >= 0 \
				and p.y >= 0 

	# continue to next column, reset line
	var col_step: Callable
	# the column is over
	var col_condition: Callable
	
	#-- utility functions --#
	var posx_eq_max := func(position : Vector2i): return position.x == board_size - 1
	var posx_eq_0 := func(position : Vector2i): return position.x == 0
	
	var posy_eq_max = func(position : Vector2i): return position.y == board_size - 1
	var posy_eq_0 = func(position : Vector2i): return position.y == 0


	match direction:
		Vector2i.LEFT:
			pos = Vector2i.ZERO
			
			line_step = Vector2i(1,0)
			col_step = func(position : Vector2i): position.y += 1; position.x = 0; return position
			
			line_end_condition = posx_eq_max
			col_condition = posy_eq_max
			
		Vector2i.RIGHT:
			pos = Vector2i(board_size - 1, 0)
			
			line_step = Vector2i(-1,0)
			col_step = func(position : Vector2i): position.y += 1; position.x = board_size - 1; return position
			
			line_end_condition = posx_eq_0
			col_condition = posy_eq_max
			
		Vector2i.DOWN:
			pos = Vector2i(0, board_size - 1)
			
			line_step = Vector2i(0, -1)
			col_step = func(position : Vector2i): position.x += 1; position.y = board_size - 1; return position
			
			line_end_condition = posy_eq_0
			col_condition = posx_eq_max
			
		Vector2i.UP:
			pos = Vector2i.ZERO
			
			line_step = Vector2i(0, 1)
			col_step = func(position : Vector2i): position.x += 1; position.y = 0; return position
			
			line_end_condition = posy_eq_max
			col_condition = posx_eq_max
		
		_: 
			printerr("invalid direction ignored: ", direction)
			return
	# we increment line until condition
	# then column and reset line until column condition
	while not (col_condition.call(pos) and line_end_condition.call(pos)):
		while not line_end_condition.call(pos):
			pos += line_step # it's okay to skip the first position of each line 
							#  since there's nowhere to move or merge
			if _board_get(pos) == null:
				continue
			# check positions to move the cell to/ merge the cell with
			var cursor = pos - line_step
			
			while in_bounds.call(cursor):
				var is_last = not in_bounds.call(cursor - line_step)
				if  is_last and _board_get(cursor) == null:
					board[cursor.x][cursor.y] = _board_get(pos)
					board[pos.x][pos.y] = null
					block_moved.emit(pos, cursor)
					
				elif _board_get(cursor) == null:
					pass

				elif _board_get(cursor) != _board_get(pos): 
					# cant fuse, move it to before
					var before = cursor + line_step
					if before != pos:
						board[before.x][before.y] = _board_get(pos)
						board[pos.x][pos.y] = null
						block_moved.emit(pos, before)
						if recursive: # go to line start
							while in_bounds.call(pos - line_step):
								pos -= line_step
					break
					
				elif _board_get(cursor) == _board_get(pos):
					if cursor == pos:
						printerr("unreacheable eq")
					block_fused.emit(pos, cursor, board[cursor.x][cursor.y] + 1)
					board[pos.x][pos.y] = null
					board[cursor.x][cursor.y] += 1
					if recursive: # go to line start
							while in_bounds.call(pos - line_step):
								pos -= line_step
					break
				else: printerr("unreachable")
				cursor -= line_step
			
		if col_condition.call(pos) and line_end_condition.call(pos):
			continue
			
		pos = col_step.call(pos)
		
func is_move_valid(dir : Vector2i) -> bool:
	var clone = Board.new()
	clone.board = board.duplicate(true)
	
	clone._on_move(dir)
	return clone.board != board

func no_move_left() -> bool:
	return [
			Vector2i.RIGHT, Vector2i.LEFT,
			Vector2i.UP,Vector2i.DOWN
		].all(func(x): return not is_move_valid(x))
	

func pprint():
	var t = ""
	for y in range(board_size):
		for x in range(board_size):		
			t += str(board[x][y] if board[x][y] != null else "_") + " "
		t += "\n"
	print(t)

### TEST ONLY
func _input(event):
	return
	if event is InputEventKey:
		if (get_child(0) as Timer).is_stopped():
			(get_child(0) as Timer).start()
		else:
#				print("time out")r
			return
		match event.keycode:
			KEY_R: 
				random_populate()
				pprint()
			KEY_LEFT:  
				_on_move(Vector2i.LEFT)
				pprint()
			KEY_RIGHT:
				_on_move(Vector2i.RIGHT)
				pprint()
			KEY_DOWN: 
				_on_move(Vector2i.DOWN)
				pprint()
			KEY_UP:
				_on_move(Vector2i.UP)
				pprint()

