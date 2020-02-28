extends KinematicBody2D

enum CollisionResponse {
    FREE, JAMMED
}

const DEBUG := false

export var speed: int = 0
export var radius: float = 5

var _velocity = Vector2(1, 0).normalized()
var _last_collision_response: int
var _captured := false


func _ready():
    $CollisionShape2D.shape.radius = radius
    $Circle.radius = radius


func _input(event):
    if DEBUG:
        _process_mouse_drags(event)


func _physics_process(delta):
    if speed == 0 or _captured: return
    
    var collision = move_and_collide(speed * _velocity * delta)
    if collision:
        if _last_collision_response == CollisionResponse.FREE and not $PopSound.playing:
            $PopSound.play()

        _last_collision_response = _respond_to_collision(collision)

        var collided_node = collision.collider
        var collided_peer = collided_node.get_network_master()
        var this_peer = Network.get_self_id()
        if collided_peer == this_peer:
            var collider_groups = collision.collider.get_groups()
            if "remote_collidable" in collider_groups:
                rpc("_remote_update", position, _velocity)
            if "goals" in collider_groups:
                Score.goal(this_peer)
    
    _update_direction_arrow()


func update_velocity(velocity: Vector2):
    _velocity = velocity.normalized()
    _update_direction_arrow()


func show_direction_arrow():
    $ArrowTween.interpolate_property($Arrow, "modulate", null, Color(1, 1, 1, 1), 0.1)
    $ArrowTween.start()


func hide_direction_arrow():
    $ArrowTween.interpolate_property($Arrow, "modulate", null, Color(1, 1, 1, 0), 0.1)
    $ArrowTween.start()


func _respond_to_collision(collision: KinematicCollision2D) -> int:
    var velocity = _velocity
    
    velocity = velocity.bounce(collision.normal)
    velocity = velocity.normalized()

    var max_rebound_count = 3
    var remainder_length: float = collision.remainder.length()
    while remainder_length > 0 and max_rebound_count > 0:
        collision = move_and_collide(velocity * collision.remainder.length())
        if collision:
            var new_remainder_length = collision.remainder.length()
            if is_equal_approx(new_remainder_length, remainder_length):
                update_velocity(velocity)
                return CollisionResponse.JAMMED
            remainder_length = new_remainder_length
            velocity = velocity.bounce(collision.normal)
            velocity = velocity.normalized()
            max_rebound_count -= 1
        else:
            break
    
    update_velocity(velocity)
    return CollisionResponse.FREE


remote func _remote_update(position, velocity):
    self.position = position
    update_velocity(velocity)


func _process_mouse_drags(event):
    if event is InputEventMouseButton:
        _captured = event.pressed
    if _captured and event is InputEventMouseMotion:
        move_and_collide(event.relative)


func _update_direction_arrow():
    $ArrowTween.interpolate_property($Arrow, "end", null, _velocity * 50, 0.1)
    $ArrowTween.start()
