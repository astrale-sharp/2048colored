extends ColorRect

@export var COLORS: = [
	Color.WHITE, Color.SKY_BLUE,Color.LIGHT_CORAL, Color.ORANGE_RED,
	Color.DARK_RED, Color.PINK, Color.LAWN_GREEN, Color.PURPLE
]

var CHARS = ["𝛂", "𝜷", "𝛾", "Ѻ"]


var level : int = 0

func appear():
	pass

func move_to():
	pass
	
func fade_out():
	pass

func level_up():
	
	level += 1
	# if > 0, add a label
	var rest = __wrap_level(level)
	var next_color =  COLORS[ level % COLORS.size() - 1 ]
	#anim

func __wrap_level(level):
	var i = 0
	var val = level
	while val >= 0:
		i += 1
		val = level - (COLORS.size() ) * i
	return i - 1


func _ready():
	for k in range(50):
		print(k," : ", __wrap_level(k))
	
