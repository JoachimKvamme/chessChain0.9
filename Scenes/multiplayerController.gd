extends Control

@export var adress = "127.0.0.1"
@export var port = 8910

var peer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func peer_connected(id):
	print("Player connected " + str(id))

func peer_disconnected(id):
	print("Player disconnected " + str(id))

func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed")
	
func players():
	GameManager.players
	
@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i) 

func _on_host_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	
	if error != OK:
		print("Cannot host: " + str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Venter på spillere")
	send_player_information($LineEdit.text, multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(adress, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	pass # Replace with function body.


func _on_button_button_down() -> void:
	print(GameManager.players)
	print("Start spill")
	pass # Replace with function body.
