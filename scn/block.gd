extends ColorRect
class_name Block

@export var game_over_animation_duration := 3.0

signal animation_finished


var level : int = 0

# used to highlight this specific block with a shader effect
var selected := false:
	set(val):
		if selected == val: return
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
	### TEST ONLY
	appear()
	return 
	set_process_input(true)

### ANIMATIONS


func game_over():
	var start_time := randf_range(0,0.3)
	
	var dir = [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT].pick_random()
	
	await get_tree().create_timer(randf_range(1.5,2)).timeout
	
	var t := create_tween() as Tween
	t.tween_property( self, ":modulate", Color.BLACK, randf_range(0.05,0.1) ) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_IN)
		
	t.parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)\
	 	.tween_property(self,"modulate:a", 0, 1)\
		.set_delay(0.1)

	t.parallel().tween_property(
		self, "position", 
		dir * ProjectSettings.get_setting("display/window/size/viewport_height"),
		game_over_animation_duration
		).as_relative()\
		.set_delay(0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	t.chain().tween_callback(func(): animation_finished.emit())

#func shake(t = create_tween()):
	#var shake = 5
	#var shake_duration = 0.1
	#var shake_count = 10
	#for i in shake_count:
		#t.tween_property(
			#self, "position", 
			#Vector2(randf_range(-shake, shake), randf_range(-shake, shake)), 
			#shake_duration
		#).as_relative()

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
	
# This animation frees the node
func fade_out(t = create_tween()):
	z_index = - 5
	
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)\
	 .tween_property(self,"modulate:a", 0, 0.2)
	t.tween_callback(queue_free)
	
var __cache = []
## caches all the future shards so that it computes easy
## Should be called when self is at position 0 0
##
## Reduces the lag on android
func __prepare_fracture():
	var pf := PolygonFracture.new()
	var rect : Rect2 = self.get_rect() as Rect2
	var rect_as_poly = PackedVector2Array( 
			[
				rect.position,
				rect.position + Vector2(rect.size.x,0),
				rect.position + rect.size, 
				rect.position + Vector2(0, rect.size.y)
			])
	var center = pf.fracture(rect_as_poly, self.get_transform(),0,1.0)[0]["centroid"]
	var res = pf.fracture( 
		rect_as_poly, self.get_transform(), 
		7 if OS.get_name() != "Android" else 4,
		1.0
		)
	
	for data in res:
		var shape = data["shape"]
		var rb := RigidBody2D.new()
		var p = CollisionPolygon2D.new()
		var pp =  Polygon2D.new()
		p.polygon = shape
		pp.polygon = shape
		pp.color = Color.BLACK
		#pp.color = color
		rb.add_child(p)
		rb.add_child(pp)
		rb.gravity_scale = 0.1
		rb.linear_velocity = (data["centroid"] - center) * randf_range(15,25)
		rb.collision_layer = 0
		__cache.push_back(rb)

## Frees the Block
func fracture(used_cache = false):
	if __cache == []: __prepare_fracture()
	for rb in __cache:
		if used_cache: rb.position += position
		get_parent().add_child(rb)

	animation_finished.emit()
	queue_free()
	
func level_up():
	level += 1
	var next_color = Constants.get_wrapping_color(level)
	$Label.text = Constants.get_char(level)
	create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) \
				  .tween_property(self, "color", next_color, 0.7)

### TEST ONLY

func _input(event):
	return
	print("test mode")
	if event is InputEventKey:
		if not event.pressed: return
		
		if event.keycode == KEY_L: level_up()
		if event.keycode == KEY_F: fracture()
