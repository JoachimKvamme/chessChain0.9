extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 19293 # set up a way to add port manually
const ADRESS = "0.0.0.0" # set up a way to add IP adress manually

func _on_host_pressed(): # function for when the player press the host button
	$NetworkInfo/NetworkSideDisplay.text = "Server"
	$Menu.visible = false # removes menu from sight
	multiplayer_peer.create_server(PORT) # possibly add input directly here?
	multiplayer.multiplayer_peer = multiplayer_peer
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())
	
func _on_join_pressed():
	$NetworkInfo/NetworkSideDisplay.text = "Client"
	$Menu.visible = false
	multiplayer_peer.create_client(ADRESS, PORT) 
	multiplayer.multiplayer_peer = multiplayer_peer
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())
	
