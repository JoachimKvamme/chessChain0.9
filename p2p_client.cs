using Godot;
using System;

public partial class NetworkClient : Node
{
	private ENetMultiplayerPeer _peer;

	public override void _Ready() // Might want to remove this and proceed directly to ConnectToServer
	{
		string ipAddress = "127.0.0.1";
		int port = 40404;
		ConnectToServer(ipAddress, port);
	}

	public void ConnectToServer(string ipAddress, int port)
	{
		_peer = new ENetMultiplayerPeer(); 
		_peer.CreateClient(ipAddress, port);
		
		// Set the multiplayer peer using Multiplayer
		Multiplayer.MultiplayerPeer = _peer;

		Multiplayer.PeerConnected += OnPeerConnected;
		Multiplayer.PeerDisconnected += OnPeerDisconnected;
		Multiplayer.ConnectionFailed += OnConnectionFailed;
		Multiplayer.ServerDisconnected += OnServerDisconnected;
	}

	private void OnPeerConnected(long id)
	{
		GD.Print($"{id}: Connected successfully!");
	}

	private void OnPeerDisconnected(long id)
	{
		GD.Print($"{id}: Disconnected from server!");
	}
	
	private void OnConnectionFailed()
	{
		GD.Print($"Connection failed");
	}
	
	private void OnServerDisconnected()
	{
		GD.Print($"Connection to server lost");
	}

	// Call this method to send a move to the server
	public void SendMove(string move)
	{
		if (Multiplayer.MultiplayerPeer == null || !Multiplayer.IsServer() && Multiplayer.GetUniqueId() == 0)
		{
			GD.PrintErr("Cannot send move: Not connected to the server.");
			return;
		}
		RpcId(1, nameof(SendMoveRemote), move); // Send move to server with ID=1
	}

	// This will be called remotely on the server
	[Rpc]
	public void SendMoveRemote(string move)
	{
		GD.Print($"Move received: {move}");
	}
}
