tool
class_name Player
extends KinematicBody2D

export var speed: int = 200
export var additional_speed: int = 0
export(float, 90) var max_tilt: float = 40

puppet var _velocity := Vector2()

onready var _tween = $TiltTween
var _current_target_tilt = 0


func init(_name: String, color: Color, start_position: Vector2):
	$ColorRect.color = color
	position = start_position


func _physics_process(delta):
	if not Engine.is_editor_hint() and is_network_master():
		_velocity = Vector2()
		var tilt = 0
		if Input.is_action_pressed("ui_right"):
			_velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			_velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			_velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			_velocity.y -= 1
		if Input.is_action_pressed("ui_tilt_clockwise"):
			tilt += max_tilt
		if Input.is_action_pressed("ui_tilt_counter_clockwise"):
			tilt -= max_tilt
		_velocity = _velocity.normalized() * (speed + additional_speed)
		_move(_velocity, delta)
		rpc("_update_position_and_velocity", position, _velocity)
		if tilt != _current_target_tilt:
			_current_target_tilt = tilt
			rpc("_tilt", tilt)
	else:
		_move(_velocity, delta)


remotesync func _tilt(deg: float):
	var rad = deg2rad(deg)
	_tween.stop_all()
	_tween.interpolate_property(self, "rotation", null, rad, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()


func _move(velocity, _delta):
	move_and_slide(velocity)


puppet func _update_position_and_velocity(position, velocity):
	move_and_collide(position - self.position)
	self._velocity = velocity
