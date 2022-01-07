extends Node

signal on_new_player(peer_id, info)

const Player = preload("res://scenes/Player.tscn")
const MAX_PLAYERS = 1

var players = {}
var self_data = _new_user_data()
var server_port: int = -1

var _peer := NetworkedMultiplayerENet.new()


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("network_peer_connected", self, "_on_player_connected")


func create_server(port: int, player_nickname: String, player_color: Color):
	disconnect_from_network()
	if _peer.create_server(port, MAX_PLAYERS, 1, 1) != OK:
		return FAILED
	get_tree().set_network_peer(_peer)
	self_data = _new_user_data()
	self_data.name = player_nickname
	self_data.color = player_color
	players[1] = self_data
	server_port = port
	return OK


func connect_to_server(host: String, port: int, player_nickname: String, player_color: Color):
	disconnect_from_network()
	if _peer.create_client(host, port) != OK:
		return FAILED
	get_tree().set_network_peer(_peer)
	self_data = _new_user_data()
	self_data.name = player_nickname
	self_data.color = player_color
	players[_peer.get_unique_id()] = self_data
	return OK


func disconnect_from_network():
	_peer.close_connection()
	get_tree().set_network_peer(null)
	players.clear()


func get_self_id() -> int:
	return get_tree().get_network_unique_id()


func is_server() -> bool:
	return get_tree().is_network_server()


func _on_player_disconnected(id):
	players.erase(id)


func _on_player_connected(connected_player_id):
	rpc_id(connected_player_id, "_send_player_info", get_self_id(), self_data)


remote func _send_player_info(peer_id, info):
	var emit_on_new_player = false if peer_id in players else true
	players[peer_id] = info
	if emit_on_new_player:
		emit_signal("on_new_player", peer_id, info)


func _new_user_data():
	return {name = "", color = Color.white, score = 0}
