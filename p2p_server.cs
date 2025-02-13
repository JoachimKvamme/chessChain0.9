using System;
using Godot;

public partial class NetworkServer : Node
{
	private ENetMultiplayerPeer _peer;

	public void StartServer()
	{
		
		GD.Print("starter server");
		_peer = new ENetMultiplayerPeer();
		_peer.CreateServer(40404);

		Multiplayer.MultiplayerPeer = _peer;

		Multiplayer.PeerConnected += OnPeerConnected;
		Multiplayer.PeerDisconnected += OnPeerDisconnected;
	}

	private void OnPeerConnected(long id)
	{
		GD.Print($"Peer connected: {id}");
	}

	private void OnPeerDisconnected(long id)
	{
		GD.Print($"Peer disconnected: {id}");
	}

	[Rpc]
	public void SendMoveRemote(string move)
	{
		GD.Print($"Move received from client: {move}");
	}
}
