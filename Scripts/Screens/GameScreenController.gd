extends Node

const DEBUG := false

onready var _ballManager := $"%BallManager"
onready var _saveManager := $"%SaveManager"
onready var _hudManager := $"%HudManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	_ballManager.connect("ballsMerged", self, "_onBallsMerged")
	
	var exponents = _saveManager.loadGame()
	if DEBUG:
		exponents.clear()
		for i in range(30):
			exponents.append(2)
	if len(exponents) > 0:
		yield(_ballManager.spawnBalls(exponents), "completed")
		
	_ballManager.startGame()

func _onBallsMerged():
	if !DEBUG:
		_saveManager.saveGame(_ballManager.getActiveBalls())
