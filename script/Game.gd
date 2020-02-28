extends Node

signal countdown_finished

const Player = preload("res://scenes/Player.tscn")


func _ready():
    Network.connect("on_new_player", self, "_on_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
    get_tree().connect("server_disconnected", self, "_on_server_disconnected")
    Score.connect("score_updated", self, "_on_score_updated")
    
    for player in Network.players:
        _add_new_player(player, Network.players[player])
    
    $UI/Countdown.visible = false
    _pause_game()
    
    if (Network.is_server()):
        ServerDiscovery.start_broadcasting_im_server(Network.server_port)
        
    if Network.players.size() == 2:
        rpc("_start_game_with_animation")


func _add_new_player(peer_id: int, info: Dictionary):
    var color = info.color
    
    var player_stuff = _get_player_stuff(peer_id)
    player_stuff.set_network_master(peer_id)
    var player_score := player_stuff.get_node("Score") as Label
    player_score.visible = true
    player_score.add_color_override("font_color", color)
    player_score.text = str(info.score)
    var start_position = player_stuff.get_node("SpawnPoint").position
    
    var new_player = Player.instance()
    new_player.name = str(peer_id)
    new_player.set_network_master(peer_id)
    new_player.init(info.name, color, start_position)
    add_child(new_player)
    
    
func _to_lobby():
    if Network.is_server():
        ServerDiscovery.stop_broadcasting_im_server()
    Network.disconnect_from_network()
    SceneNavigator.nav_to_main()
    
    
remotesync func _start_game_with_animation():
    $UI/Countdown.visible = true
    $Ball.show_direction_arrow()
    _enable_start_game_after_anim()
    $CountdownAnimation.play("countdown3")
    
    
remotesync func _start_game(_ignored = null):
    _resume_game()


func _restart_game(new_ball_direction: Vector2):
    for player in Network.players:
        var player_stuff = _get_player_stuff(player)
        var player_node = get_node(str(player))
        player_node.position = player_stuff.get_node("SpawnPoint").position
    _reset_ball(new_ball_direction)
    _start_game_with_animation()
    
    
remotesync func _resume_game():
    $Ball.hide_direction_arrow()
    $Ball.speed = 700
    
    
remotesync func _pause_game():
    $Ball.show_direction_arrow()
    $Ball.speed = 0
    
    
func _on_player_connected(peer_id, info):
    _add_new_player(peer_id, info)
    rpc("_start_game_with_animation")


func _on_player_disconnected(peer_id):
    get_node(str(peer_id)).queue_free()
    var player_stuff = _get_player_stuff(peer_id)
    player_stuff.set_network_master(1)
    player_stuff.get_node("Score").visible = false
    
    _disable_start_game_after_anim()
    $CountdownAnimation.clear_queue()
    $UI/Countdown.visible = false
    Network.self_data.score = 0
    _get_player_stuff(1).get_node("Score").text = "0"
    _reset_ball(Vector2(1, 0))
    _pause_game()


func _on_server_disconnected():
    _to_lobby()
    
    
func _on_score_updated(peer_id: int, score: int):
    var player_score := _get_player_stuff(peer_id).get_node("Score") as Label
    player_score.text = str(score)
    _pause_game()
    _restart_game(_ball_direction_from_winning_peer(peer_id))
    
    
func _get_player_stuff(peer_id) -> Node:
    return $Player1Stuff if peer_id == 1 else $Player2Stuff
    
    
func _enable_start_game_after_anim():
    if not $CountdownAnimation.is_connected("animation_finished", self, "_start_game"):
        $CountdownAnimation.connect("animation_finished", self, "_start_game")
    
    
func _disable_start_game_after_anim():
    if $CountdownAnimation.is_connected("animation_finished", self, "_start_game"):
        $CountdownAnimation.disconnect("animation_finished", self, "_start_game")
    
    
func _reset_ball(direction):
    $Ball.position = $BallSpawnPoint.position
    if direction:
        $Ball.update_velocity(direction)
    
    
func _ball_direction_from_winning_peer(peer_id: int) -> Vector2:
    if peer_id == 1:
        return Vector2(1, 0)
    else:
        return Vector2(-1, 0)


func _on_BackToLobby_button_up():
    _to_lobby()
