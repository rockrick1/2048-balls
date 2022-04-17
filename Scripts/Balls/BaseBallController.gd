extends RigidBody2D

signal hovered

var Exponent : int
var _value : int
var Radius : float
var _ballsManager
var _color : Color
var _selected : bool = false
var _moveDirection : Vector2
var _mergeSpeed : float = 0

func init(exponent : int, color : Color, position : Vector2, ballsManager : Node) -> void:
	_ballsManager = ballsManager
	
	if exponent == 0:
		Exponent = 1
	else:
		Exponent = exponent
	_value = pow(2, exponent)
	$CollisionShape/ValueLabel.text = str(_value)
		
	_color = color
	$CollisionShape/CircleSprite.modulate = color
	
	Radius = $CollisionShape.shape.get_radius() * $CollisionShape.scale.x
	set_position(position)

func setHighlight(highlight : bool) -> void:
	if highlight: $CollisionShape/CircleSprite.modulate = Color(1,1,1)
	else: $CollisionShape/CircleSprite.modulate = _color

func promote(exponent, color):
	_color = color
	$CollisionShape/CircleSprite.modulate = color
	Exponent = exponent
	_value = pow(2, exponent)
	$CollisionShape/ValueLabel.text = str(_value)

func select():
	# TODO visual indication
	if _selected:
		return
	_selected = true

func unselect():
	if _selected:
		# TODO merge with other balls, or just unselect
		_selected = false

# Destroys the ball and moves it towards the next ball on the merge line
func destroy(nextBall, interval : float) -> void:
	yield(mergeWithNext(nextBall, interval), "completed")
	queue_free()

func mergeWithNext(next, interval) -> void:
	set_mode(MODE_STATIC)
	$CollisionShape.disabled = true
	_moveDirection = ( next.get_global_position() - get_global_position() ).normalized()
	_mergeSpeed = next.get_global_position().distance_to(get_global_position()) / interval
	yield(get_tree().create_timer(interval), "timeout") 

func _physics_process(delta):
	setHighlight(_selected)
	if _mergeSpeed != 0:
		position += _moveDirection * delta * _mergeSpeed

func _on_BaseBall_mouse_entered():
	emit_signal("hovered", self)
