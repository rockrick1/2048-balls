extends Node

const DISTANCE_TO_CONNECT := 75.0
const MAX_ACTIVE_BALLS := 30
const SHAKE_STRENGTH := 2000
const SPAWN_INTERVAL := .001
const MERGE_SNAKING_INTERVAL := 0.075
const BASE_BALL_SCENE = preload("res://Scenes/Balls/BaseBall.tscn")

signal ballsMerged

var _minValueForSpawn := 1
var _valueRangeForSpawn := 4

onready var _ballsParent := $"%BallsParent"
onready var _ballsSpawnArea := $"%BallsSpawnArea"
onready var _spawnTimer := $"%SpawnTimer"
onready var BallColors : Array = $"%BallColors".Colors

var _holdingExponent := 0
var _gameScreen : Node
var _selectedBalls := []
var _selecting := false
var _gameStarted := false
var _merging := false

func _ready():
	_gameScreen = get_parent()
	_spawnTimer.wait_time = SPAWN_INTERVAL

func startGame() -> void:
	_spawnTimer.start()
	_gameStarted = true

func spawnBalls(exponents : Array) -> void:
	for exponent in exponents:
		spawnBall(exponent)
		yield(get_tree().create_timer(SPAWN_INTERVAL), "timeout")

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
	
	HudManager.setSum(getBallSum())

func getBallColor(exponent) -> Color:
	return BallColors[int(exponent) % len(BallColors)]

func getHoveredBall():
	var mousePos = get_viewport().get_mouse_position()
	for ball in getActiveBalls():
		if ball.get_global_position().distance_to(mousePos) <= ball.Radius: return ball

func getActiveBalls() -> Array:
	return _ballsParent.get_children()

func getBallSum() -> int:
	var sum = 0
	for ball in getActiveBalls():
		sum += ball.Value
	return sum

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
		_merging = true
		
		for i in range(len(_selectedBalls)):
			var ball = _selectedBalls[i]
			if i < len(_selectedBalls) - 1:
				yield(ball.destroy(_selectedBalls[i+1], MERGE_SNAKING_INTERVAL), "completed")
			else:
				ball.unselect()
				var newExponent = int(ball.Exponent + floor(log(len(_selectedBalls)) / log(2)))
				ball.promote(newExponent, getBallColor(newExponent))
	else:
		_selectedBalls[0].unselect()
		
	_merging = false
	
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
	if not _gameStarted or _merging:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if !event.pressed and len(_selectedBalls) > 0:
			mergeSelectedBalls()
			_selecting = false
		elif event.pressed:
			onBallClicked(getHoveredBall())
			_selecting = true


func _on_SpawnTimer_timeout():
	if len(getActiveBalls()) < MAX_ACTIVE_BALLS: spawnBall()

func _on_ShakeButton_pressed():
	shake()
