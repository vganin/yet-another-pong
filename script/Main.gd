extends Control

var _servers := []

onready var _server_list = $ServerList


func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	var cmdline_args = _get_cmdline_args_dict()
	if "host" in cmdline_args:
		_create_server(int(cmdline_args.host), "CmdServer", Color.white)
	elif "connect" in cmdline_args:
		var host_port = cmdline_args.connect.split(":")
		_connect_to_server(host_port[0], int(host_port[1]), "CmdClient", Color.white)

	ServerDiscovery.connect("server_list_updated", self, "_on_servers_list_updated")
	ServerDiscovery.start_discovering_servers()


func _gui_input(event):
	if event is InputEventMouseButton:
		_server_list.unselect_all()
		accept_event()


func _load_game():
	ServerDiscovery.stop_discovering_servers()
	SceneNavigator.nav_to_game()


func _on_servers_list_updated(servers):
	_servers = servers
	_server_list.clear()
	for server in servers:
		var text = "{0}:{1}".format({0: server.ip, 1: str(server.port)})
		_server_list.add_item(text)


func _get_cmdline_args_dict() -> Dictionary:
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	return arguments


func _create_server(port: int, player_name: String, player_color: Color):
	if Network.create_server(port, player_name, player_color) == OK:
		_load_game()


func _connect_to_server(host: String, port: int, player_name: String, player_color: Color):
	Network.connect_to_server(host, port, player_name, player_color)


func _connected_to_server():
	_load_game()


func _on_HostButton_button_up():
	_create_server(_port(), _player_name(), _player_color())


func _on_ConnectButton_button_up():
	var selected = _server_list.get_selected_items()
	if selected.size() > 0:
		var first_selected = selected[0]
		var selected_server = _servers[first_selected]
		_connect_to_server(
			selected_server.ip, selected_server.port, _player_name(), _player_color()
		)
	else:
		_connect_to_server(_host(), _port(), _player_name(), _player_color())


func _host() -> String:
	return $HostAndPort/Host.text


func _port() -> int:
	return int($HostAndPort/Port.text)


func _player_name() -> String:
	return $NameAndColor/Name.text


func _player_color() -> Color:
	return $NameAndColor/Color.color
