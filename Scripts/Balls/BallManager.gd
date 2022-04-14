extends Node

const DISTANCE_TO_CONNECT : float = 75.0
const MAX_ACTIVE_BALLS : int = 50
const SHAKE_STRENGTH : int = 2000
const BASE_BALL_SCENE = preload("res://Scenes/Balls/BaseBall.tscn")
const VALUE_TO_COLOR_MAP : Dictionary = {
	0 : Color(.5,1,0),
	1 : Color(1,0,0),
	2 : Color(0,1,0),
	3 : Color(1,1,0),
	4 : Color(0,0,1),
	5 : Color(1,0,1),
	6 : Color(0,1,1),
	7 : Color(1,1,1),
}

signal ballsMerged

var _minValueForSpawn : int = 1
var _valueRangeForSpawn : int = 4

var _ballsParent : Node
var _holdingExponent : int = 0
var _gameScreen : Node2D
var _spawnTimer : Timer
var _ballsSpawnArea : CollisionShape2D
var _selectedBalls : Array
var _hoveredBall : RigidBody2D
var _selecting : bool = false
var _gameStarted : bool = false

func _ready():
	_ballsParent = $BallsParent
	_gameScreen = get_parent()
	_ballsSpawnArea = _gameScreen.get_node("BallContainer/BallsSpawnArea")
	_selectedBalls = []
	_spawnTimer = $SpawnTimer

func startGame() -> void:
	_spawnTimer.start()
	_gameStarted = true

func spawnBalls(exponents : Array) -> void:
	for exponent in exponents:
		spawnBall(exponent)
		yield(get_tree().create_timer(.1), "timeout")

# Spawns ball at random location
func spawnBall(exponent = 0) -> void:
	if (exponent == 0):
		exponent = (randi() % _valueRangeForSpawn) + _minValueForSpawn
	
	var object = BASE_BALL_SCENE.instance()
	var spawnExtents = _ballsSpawnArea.shape.extents
	var position = Vector2(randi() % int(spawnExtents.x), randi() % int(spawnExtents.y)) \
		- (spawnExtents / 2)
	position += _ballsSpawnArea.global_position
	object.init(exponent, getBallColor(exponent), position, \
		self)
	object.connect("hovered", self, "_onOtherBallHovered")
	_ballsParent.add_child(object)

func getBallColor(exponent) -> Color:
	return VALUE_TO_COLOR_MAP[int(exponent) % len(VALUE_TO_COLOR_MAP.keys())]

func getHoveredBall():
	var mousePos = get_viewport().get_mouse_position()
	for ball in getActiveBalls():
		if ball.get_global_position().distance_to(mousePos) <= ball.Radius: return ball

func getActiveBalls() -> Array:
	return _ballsParent.get_children()

func getNearbyBalls(ball) -> Array:
	var result : Array = []
	for b in getActiveBalls():
		if b == ball or b.Exponent != ball.Exponent:
			continue
		if b.get_global_position().distance_to(ball.get_global_position()) < DISTANCE_TO_CONNECT:
			result.append(b)
	return result

func mergeSelectedBalls() -> void:
	if len(_selectedBalls) > 1:
		for i in range(len(_selectedBalls)):
			var ball = _selectedBalls[i]
			if i < len(_selectedBalls) - 1:
				ball.destroy()
			else:
				ball.unselect()
				var newExponent = int(ball.Exponent + floor(sqrt(len(_selectedBalls))))
				ball.promote(newExponent, getBallColor(newExponent))
	else:
		_selectedBalls[0].unselect()
	_selectedBalls.clear()
	emit_signal("ballsMerged")

func shake() -> void:
	for b in getActiveBalls():
		var direction = Vector2(randi() % SHAKE_STRENGTH, randi() % SHAKE_STRENGTH) + \
			Vector2(-SHAKE_STRENGTH / 2, -SHAKE_STRENGTH / 2)
		b.apply_impulse(Vector2(15,15), direction)

func onBallClicked(ball):
	if ball == null: return
	_holdingExponent = ball.Exponent
	_selectedBalls.append(ball)
	ball.select()

func _onOtherBallHovered(ball) -> void:
	if _selecting == false or len(_selectedBalls) == 0:
		return
	
	var lastSelected = _selectedBalls[-1]
	var secondLastSelected = _selectedBalls[len(_selectedBalls) - 2]
	
	if len(_selectedBalls) > 1 and ball == secondLastSelected:
		lastSelected.unselect()
		_selectedBalls.pop_back()
		return
	
	if _selecting == false or _selectedBalls.has(ball) or ball.Exponent != _holdingExponent \
		or not getNearbyBalls(lastSelected).has(ball):
		return
	
	_selectedBalls.append(ball)
	ball.select()

func _unhandled_input(event):
	if not _gameStarted:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if !event.pressed and len(_selectedBalls) > 0:
			mergeSelectedBalls()
			_selecting = false
		elif event.pressed:
			onBallClicked(getHoveredBall())
			_selecting = true

func _process(delta):
	$BallCountLabel.set_text(str(_ballsParent.get_child_count()))

func _on_SpawnTimer_timeout():
	if len(getActiveBalls()) < MAX_ACTIVE_BALLS: spawnBall()

func _on_ShakeButton_pressed():
	shake()
