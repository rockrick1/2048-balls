extends Node

var _ballManager : Node
var _saveManager : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	_ballManager = $BallManager
	_saveManager = $SaveManager
	
	_ballManager.connect("ballsMerged", self, "_onBallsMerged")
	
	var exponents = _saveManager.loadGame()
	if len(exponents) > 0:
		yield(_ballManager.spawnBalls(exponents), "completed")
		
	_ballManager.startGame()

func _onBallsMerged():
	_saveManager.saveGame(_ballManager.getActiveBalls())

func _on_SaveButton_pressed():
	_saveManager.saveGame(_ballManager.getActiveBalls())
