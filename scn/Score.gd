extends Label
class_name Score

var score = 0:
	set(val):
		score = val
		text = "score :" + str(score)

func _on_level_appear(level : int):
	score += pow(2, level)
