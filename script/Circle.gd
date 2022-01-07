tool
extends Node2D

export var color = Color.white
export var radius: float = 20


func _draw():
	draw_circle(Vector2(0, 0), radius, color)
