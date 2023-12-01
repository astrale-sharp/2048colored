extends Control
class_name Wheel

signal animation_finished
@export var amplitude = 10
#@export 
@export var heigth_per_block:   int = 40
@export var animation_on := true
var game_over_mode := false


var block = preload("res://scn/block.tscn")

func _on_level_appear(level):
	index = max(level, index)

func _on_game_over_animation_start():
	game_over_mode = true
	await get_tree().create_timer(1.2).timeout
	
	set_physics_process(false)
	
	await get_tree().create_timer(1.5).timeout
	
	for c in get_children():
		var b: Block = c as Block
		b.fracture(true)
	await get_tree().create_timer(3).timeout
	animation_finished.emit()


func _ready():
	for c in get_children():
		c.queue_free()
		
	for k in range( Constants.COLORS.size() ):
		var c = Constants.COLORS[k]
		var b = block.instantiate() as Block
		b.color = c
		b.__prepare_fracture()
		add_child(b)

var t = randi_range(0,40000)
var index := 0:
	set(val):
		( get_child(index) as Block ).selected = false
		index = val
		( get_child(index) as Block ).selected = true
		
var base
func _physics_process(delta: float) -> void:
	if not animation_on: return
	t+= delta/5
	var tt = log(t*t) * exp( cos(t) )
	base = Vector2.ONE *50 + amplitude * Vector2(cos(tt),sin(tt) )

	for k in get_child_count():
		var c = get_child(k)
		var a = 0 if not game_over_mode else randf() * 8
		
		var ttt = log(tt*tt + 30)* exp( cos(tt + 2*k + 30) )
#		var ttt = log( 1 + (t*t) ) * exp( cos(t +5*k) ) 
		c.position = base  \
					+ heigth_per_block * k * Vector2.RIGHT \
					+ amplitude * Vector2(cos(ttt + a), sin(ttt + a))


### TEST ONLY
func _input(event):
	return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			_on_game_over_animation_start()

