extends Node

signal score_updated(scored_player, score)


func goal(goal_received: int):
    rpc("_goal", goal_received)
    
    
sync func _goal(goal_received: int):
    var scored_player = _calculate_scored_player(goal_received)
    if scored_player:
        var score_player_info = Network.players[scored_player]
        score_player_info.score += 1
        emit_signal("score_updated", scored_player, score_player_info.score)


func _calculate_scored_player(goal_received: int):
    var scored_player: int
    for other_peer_id in Network.players:
        if other_peer_id != goal_received: 
            scored_player = other_peer_id
            break
    return scored_player
