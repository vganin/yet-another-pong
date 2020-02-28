tool
extends Node2D

export var dash_length: float = 5
export var cap_end: bool = false
export var antialiased: bool = false

onready var _source_line = $SourceLine
onready var _points = _source_line.points
onready var _color = _source_line.default_color
onready var _width = _source_line.width


func _draw():
    if _points.size() != 2: return
    draw_set_transform_matrix(transform.inverse())
    _draw_dashed_line(_points[0], _points[1], _color, _width, dash_length, cap_end, antialiased)


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float, dash_length: float, cap_end: bool, antialiased: bool):
    var length = (to - from).length()
    var normal = (to - from).normalized()
    var dash_step = normal * dash_length
    
    if length < dash_length: #not long enough to dash
        draw_line(from, to, color, width, antialiased)
        return
    else:
        var draw_flag = true
        var segment_start = from
        var steps = length/dash_length
        for start_length in range(0, steps + 1):
            var segment_end = segment_start + dash_step
            if draw_flag:
                draw_line(segment_start, segment_end, color, width, antialiased)

            segment_start = segment_end
            draw_flag = !draw_flag
        
        if cap_end:
            draw_line(segment_start, to, color, width, antialiased)
