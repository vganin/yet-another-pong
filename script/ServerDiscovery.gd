extends Node

signal server_list_updated(server_list)

const BROADCAST_ADDRESS = "255.255.255.255"
const LOCALHOST = "127.0.0.1"
const SERVER_PORT = 111778  # For server to write and client to listen
const CLIENT_PORT = 111779  # For client to write and server to listen

const MSG_SERVER_TEMPLATE = """{ 
    \"who\": \"server\",
    \"status\": \"{status}\",
    \"port\": %d
}"""
var MSG_SERVER_HELLO = MSG_SERVER_TEMPLATE.format({"status": "up"})
var MSG_SERVER_BYE = MSG_SERVER_TEMPLATE.format({"status": "down"})
const MSG_CLIENT_HELLO = """{ 
    \"who\": \"client\"
}"""
const MSG_STOP = "Stop"

var _thread := Thread.new()
var _server_udp := PacketPeerUDP.new()
var _client_udp := PacketPeerUDP.new()


func _ready():
	_server_udp.set_broadcast_enabled(true)
	_client_udp.set_broadcast_enabled(true)


func start_discovering_servers():
	if not _thread.is_active():
		_thread.start(self, "_discover_servers")


func stop_discovering_servers():
	if _thread.is_active():
		_server_udp.set_dest_address(LOCALHOST, SERVER_PORT)
		_server_udp.put_packet(MSG_STOP.to_ascii())
		_thread.wait_to_finish()


func _discover_servers(_null):
	print("Discovering servers")

	if _server_udp.listen(SERVER_PORT) != OK:
		print("Failed to listen UDP socket for server responses %d" % SERVER_PORT)
		return

	_client_udp.set_dest_address(BROADCAST_ADDRESS, CLIENT_PORT)
	_client_udp.put_packet(MSG_CLIENT_HELLO.to_ascii())

	var servers := {}

	while _server_udp.wait() == OK:
		if _server_udp.get_available_packet_count() > 0:
			var data = _server_udp.get_packet().get_string_from_ascii()

			if data == MSG_STOP:
				print("Stopping server broadcasting...")
				break

			var json = JSON.parse(data)
			if json.error != OK:
				push_error("Json parsing error: %s" % json.error_string)

			if json.result.who == "server":
				var ip = _server_udp.get_packet_ip()
				var port = json.result.port
				if json.result.status == "up":
					print("Server says hello: %s:%d" % [ip, port])
					var server := _new_server_info(ip, port)
					servers[hash(server)] = server
					call_deferred("emit_signal", "server_list_updated", servers.values())
				elif json.result.status == "down":
					print("Server says bye: %s:%d" % [ip, port])
					var server := _new_server_info(ip, port)
					servers.erase(hash(server))
					call_deferred("emit_signal", "server_list_updated", servers.values())
				else:
					push_error("Undefined message: %s" % data)
			else:
				push_error("Undefined message: %s" % data)

	_server_udp.close()
	_client_udp.close()


func start_broadcasting_im_server(server_port: int):
	if not _thread.is_active():
		_thread.start(self, "_broadcast_im_server", server_port)


func stop_broadcasting_im_server():
	if _thread.is_active():
		_client_udp.set_dest_address(LOCALHOST, CLIENT_PORT)
		_client_udp.put_packet(MSG_STOP.to_ascii())
		_thread.wait_to_finish()


func _broadcast_im_server(server_port: int):
	print("Broadcasting I\'m a server on port %d" % server_port)

	_server_udp.set_dest_address(BROADCAST_ADDRESS, SERVER_PORT)
	_server_udp.put_packet((MSG_SERVER_HELLO % server_port).to_ascii())

	if _client_udp.listen(CLIENT_PORT) != OK:
		print("Failed to listen UDP socket for client requests %d" % CLIENT_PORT)
		return

	while _client_udp.wait() == OK:
		if _client_udp.get_available_packet_count() > 0:
			var data = _client_udp.get_packet().get_string_from_ascii()

			if data == MSG_STOP:
				print("Stopping server broadcasting...")
				break

			var json = JSON.parse(data)
			if json.error != OK:
				push_error("Json parsing error: %s" % json.error_string)

			if json.result.who == "client":
				print("Client says hello")
				_server_udp.set_dest_address(_client_udp.get_packet_ip(), SERVER_PORT)
				_server_udp.put_packet((MSG_SERVER_HELLO % server_port).to_ascii())
			else:
				push_error("Undefined message: %s" % data)

	_server_udp.set_dest_address(BROADCAST_ADDRESS, SERVER_PORT)
	_server_udp.put_packet((MSG_SERVER_BYE % server_port).to_ascii())

	_server_udp.close()
	_client_udp.close()


func _new_server_info(ip: String, port: int) -> Dictionary:
	return {ip = ip, port = port}
