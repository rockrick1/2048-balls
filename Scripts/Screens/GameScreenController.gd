extends Node

const DEBUG : bool = true

var _ballManager : Node
var _saveManager : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	_ballManager = $BallManager
	_saveManager = $SaveManager
	
	_ballManager.connect("ballsMerged", self, "_onBallsMerged")
	
	var exponents = _saveManager.loadGame()
	if DEBUG:
		exponents.clear()
		for i in range(50):
			exponents.append(2)
	if len(exponents) > 0:
		yield(_ballManager.spawnBalls(exponents), "completed")
		
	_ballManager.startGame()

func _onBallsMerged():
	if !DEBUG:
		_saveManager.saveGame(_ballManager.getActiveBalls())
