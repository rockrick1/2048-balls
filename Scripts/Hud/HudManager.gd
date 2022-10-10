extends Node

onready var _ballSumLabel := $"%BallSumLabel"


func setSum(sum : int) -> void:
	if _ballSumLabel == null:
		return
	_ballSumLabel.set_text(str(sum))
