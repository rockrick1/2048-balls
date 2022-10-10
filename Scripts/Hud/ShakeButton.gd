extends Node


var _spinSpeed : float = 0

func _on_ShakeButton_pressed():
	$"%BallsAnimation".play("shake")
