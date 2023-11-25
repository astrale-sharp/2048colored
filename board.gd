extends Node
# This script deals with the board logic

@export var board_size = 5

signal block_created( pos : Vector2i, level : int)
signal block_fused(from : Vector2i, to : Vector2i)


# board[x][y] = null | int
var board := {}

func _ready():
	for x in range(board_size):
		board[x] = {}
		for y in range(board_size):
			board[x][y] = null
	
	_on_random_populate()
	_on_random_populate()
	_on_random_populate()
	_on_random_populate()
	_on_random_populate()
	_on_random_populate()
	pprint()
	_on_move(Vector2i.RIGHT)
	pprint()
	
func _board_get(pos : Vector2i):
	board[pos.x].get(pos.y)

func _get_available_tiles() -> Array:
	var res = []
	for x in range(board_size):
		for y in range(board_size):
			if board[x].get(y) == null:
				res.push_back(Vector2i(x,y))
	return res

func _on_random_populate():
	for k in randi_range(1,2):
		var pos : Vector2i = _get_available_tiles().pick_random()
		var level = randi_range(0,1)
		board[pos.x][pos.y] = level
		block_created.emit(pos, level)
		

func _on_move(direction : Vector2i):
	var pos : Vector2i

	# continue aling this line
	var line_step
	var line_unstep
	# this line is over
	var line_condition

	# continue to next column, reset line
	var col_step
	#the columns are over
	var col_condition
	
	var posx_eq_max := func(position : Vector2i): return position.x == board_size - 1
	var posy_eq_max = func(position : Vector2i): return position.y == board_size - 1
	var posx_plus_one := func(position : Vector2i): position.x += 1; return position
	var posx_minus_one := func(position : Vector2i): position.x -= 1; return position
	var posy_plus_one_posx_to_0 := func(position : Vector2i): position.y += 1; position.x = 0; return position

	match direction:
		# if right, for each y, logic on x starting at max coord
		Vector2i.LEFT:
			pos = Vector2i.ZERO
			
			line_condition = posx_eq_max
			line_step = posx_plus_one 
			line_unstep = posx_minus_one #TODO the others
			
			col_step = posy_plus_one_posx_to_0
			col_condition = posy_eq_max
			
			
		Vector2i.RIGHT:
			pos = Vector2i(board_size - 1, 0)
			
			line_condition = func(position : Vector2i): return position.x == 0
			line_step = func(position : Vector2i): position.x -= 1; return position
			
			col_step = func(position : Vector2i): position.y += 1; position.x = board_size - 1; return position
			col_condition = func(position : Vector2i): return position.y == board_size - 1
			
			
		Vector2i.DOWN:
			pos = Vector2i(0, board_size - 1)
			
			line_condition = func(position : Vector2i): return position.y == 0
			line_step = func(position : Vector2i): position.y -= 1; return position
			
			col_step = func(position : Vector2i): position.x += 1; position.y = board_size - 1; return position
			col_condition = func(position : Vector2i): return position.x == board_size - 1
			
			
			
		Vector2i.UP:
			pos = Vector2i.ZERO
			line_condition = func(position : Vector2i): return position.y == board_size - 1
			line_step = func(position : Vector2i): position.y += 1; return position

			col_step = func(position : Vector2i): position.x += 1; position.y = 0; return position
			col_condition = posx_eq_max
		
		_:
			printerr("invalid direction ignored: ", direction)


	while not (col_condition.call(pos) and line_condition.call(pos)) : 
		
		while not line_condition.call(pos):
			pos = line_step.call(pos)
			if not _board_get(pos) != null:
				continue
			
			var cursor = pos
			while not line_condition.call(cursor):
				cursor = line_step.call(cursor)
				if not _board_get(cursor) != null:
					continue
				if _board_get(cursor) != _board_get(pos):
					# todo, move the block
					break
				else:
					block_fused.emit(pos, cursor)
					board[pos.x][pos.y] = null
					board[cursor.x][cursor.y] += 1
					cursor = pos
			
			# if collide, reset line?
			
		if col_condition.call(pos) and line_condition.call(pos):
			continue
			
		pos = col_step.call(pos)
		

func pprint():
	var t = ""
	for y in range(board_size):
		for x in range(board_size):		
			t += str(board[x][y] if board[x][y] else "_") + " "
		t += "\n"
	print(t)
#	print(board)
