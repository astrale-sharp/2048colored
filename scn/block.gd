extends ColorRect
class_name Block

var level : int = 0
var selected := false:
	set(val):
		selected = val
		if selected:
			#TODO activate shader
			pass
		else:
			#TODO deactivate shader
			pass
			
func _ready():
	scale = Vector2.ZERO
	visible = true
	if owner == null:
		appear()
		set_process_input(true)

func _input(event):
	if owner != null: return
	if event is InputEventKey:
		if event.keycode == KEY_L:
			level_up()

func appear():
	create_tween() \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property(self,"scale",Vector2.ONE,0.7)

func move_to(pos : Vector2):
	create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK) \
		.tween_property(self,"position", pos, 0.7) 
	
func fade_out():
	z_index = - 5
	var t = create_tween()
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)\
	 .tween_property(self,"modulate:a", 0, 0.2)
	t.tween_callback(queue_free)
	
func level_up():
	level += 1
	
	# color
	var next_color = Constants.get_wrapping_color(level)
	$Label.text = Constants.get_char(level)
	create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) \
				  .tween_property(self, "color", next_color, 0.7)
