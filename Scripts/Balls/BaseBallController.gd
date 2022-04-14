extends Node2D

signal hovered

var Exponent : int
var _value : int
var Radius : float
var _ballsManager
var _color : Color
var _selected : bool = false

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

func destroy() -> void:
	#TODO add some animations
	queue_free()

# TODO remove this after debugging
func _process(delta):
	setHighlight(_selected)

func _on_BaseBall_mouse_entered():
	emit_signal("hovered", self)
