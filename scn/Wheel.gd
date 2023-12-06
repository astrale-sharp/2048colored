extends Control
class_name Wheel

signal animation_finished

# amplitude of circular movements
@export var amplitude = 10
# gap between blocks of the wheel
@export var gap_per_block:= Vector2(Constants.CELL_SIZE * 0.8, Constants.CELL_SIZE * 1.2)

@export var animation_on := true


var cell_size = Constants.CELL_SIZE
# Will only be computed after ready
var total_width

# Apply special effect to current best block
var index := 0:
	set(val):
		if val == index: return
		(get_child(index % get_child_count()) as Block).selected = false
		index = val
		(get_child(index % get_child_count()) as Block).selected = true

var block = preload("res://scn/block.tscn")

## To layout this node, it will try to fit the block line in the screen
## and split it in two fract times.

# capped to five for estethic reasons
var fract = 0
func _ready():
	for c in get_children():
		c.queue_free()

	total_width = Constants.COLORS.size() * (gap_per_block.x)
	while total_width > Constants.SCREEN_SIZE.x:
		total_width /= 2
		fract += 1
		if fract >= 5: break

	for k in range( Constants.COLORS.size() ):
		var c = Constants.COLORS[k]
		var b = block.instantiate() as Block
		b.color = c
		b.size = Vector2.ONE * cell_size
		b.__prepare_fracture()
		add_child(b)
	

func _on_level_appear(level):
	index = max(level, index)

# used to tweak the animation in _physics_process
var game_over_mode := false
func _on_game_over_animation_start():
	game_over_mode = true
	await get_tree().create_timer(1.2).timeout
	
	set_physics_process(false)
	
	await get_tree().create_timer(1.5).timeout
	
	for c in get_children():
		var b: Block = c as Block
		b.fracture(true)
	await get_tree().create_timer(4.0 + randf_range(0,2) ).timeout
	animation_finished.emit()

# this is symbolically the time that has passed
# used to calculate positions in the next function 
var t = randi_range(0, 40000)
# this is the rotated base of this node
var base
func _physics_process(delta: float) -> void:
	if not animation_on: return
	t+= delta/5
	var tt = log(t*t) * exp( cos(t) )
	base = Vector2.ONE * 50 + amplitude * Vector2(cos(tt),sin(tt) )

	for k in get_child_count():
		var c = get_child(k)
		var a = 0.0 if not game_over_mode else randf() * 8
		
		var ttt = log(tt*tt + 30)* exp( cos(tt + 2*k + 30) )

		# We want to overflow of one block if the number is pair because it's prettier.
		var effect_size: = get_children().size()
		if effect_size % 2 != 0 : 
			effect_size += 1
		
		var wrapped_k = floor(k % floor( (effect_size) / int(pow(2,fract))))
		var over_k    = k / floor(effect_size / int(pow(2,fract)))
		# k: 0 1 2 3 4 5 6 7 8 9 10 <-- this is just the index
		# w: 0 1 2 3 4 5 0 1 2 3 4  <-- indicates line placement
		# o: 0 0 0 0 0 0 1 1 1 1 1  <-- indicates column placement
		
		c.position = base\
					+ gap_per_block.x   \
						* Vector2.RIGHT \
						* wrapped_k \
					+ amplitude * Vector2(cos(ttt + a), sin(ttt + a))       \
					+ gap_per_block.y * over_k * Vector2.DOWN

### TEST ONLY
func _input(event):
	return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			_on_game_over_animation_start()

