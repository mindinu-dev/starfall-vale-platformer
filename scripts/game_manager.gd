extends Node

var score = 0
@onready var label: Label = $"../Player/Label"

func add_point():
	score += 1
	print(score)
	if score == 1:
		label.text = "you collected " + str(score) + " coin"
	else:
		label.text = "you collected " + str(score) + " coins"
