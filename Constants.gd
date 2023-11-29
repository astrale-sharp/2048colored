extends Node

#@export var COLORS: = [
#	Color.WHITE, Color.SKY_BLUE,Color.LIGHT_CORAL, Color.ORANGE_RED,
#	Color.DARK_RED, Color.PINK, Color.LAWN_GREEN, Color.PURPLE
#]

@export var COLORS = [
	Color.WHITE, Color.AQUA, Color.DARK_BLUE, 
	Color.CHOCOLATE, Color.CRIMSON, Color.DARK_RED, 
	Color.DARK_GOLDENROD, Color.VIOLET, Color.DARK_VIOLET, 
	Color.DARK_GREEN, Color.INDIGO,
	]

var CHARS = ["𝛂", "𝜷", "𝛾", "Ѻ"]



func get_wrapping_color(i):
	return COLORS[ i % (COLORS.size() - 1) ]

func get_wrapping_char(rest):
	return CHARS[rest % CHARS.size() - 1]

func get_char(i):
	var rest = __wrap_level(i)
	if rest > 0: return get_wrapping_char(rest)
	else: return ""

func __wrap_level(level):
	var i = 0
	var val = level
	while val >= 0:
		i += 1
		val = level - (COLORS.size() ) * i
	return i - 1

