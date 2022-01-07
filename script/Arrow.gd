tool
extends Node2D

const WING_LENGTH = 5

export var begin := Vector2(0, 0) setget set_begin
export var end := Vector2(25, 0) setget set_end
export var color := Color.white setget set_color
export var width := 10.0 setget set_width


func _ready():
	set_begin(begin)
	set_end(end)
	set_color(color)
	set_width(width)


func set_begin(value: Vector2):
	begin = value
	if is_inside_tree():
		_update_line_points(begin, end)


func set_end(value: Vector2):
	end = value
	if is_inside_tree():
		_update_line_points(begin, end)


func set_color(value: Color):
	color = value
	if is_inside_tree():
		$Line2D.default_color = color


func set_width(value: float):
	width = value
	if is_inside_tree():
		$Line2D.width = width


func _update_line_points(begin, end):
	var points = PoolVector2Array()
	var ray = begin.direction_to(end)
	points.append(begin)
	points.append(end)
	points.append(end + ray.rotated(deg2rad(120)) * WING_LENGTH)
	points.append(end + ray.rotated(deg2rad(-120)) * WING_LENGTH)
	points.append(end)
	$Line2D.points = points
