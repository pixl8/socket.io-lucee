/**
 * Interface for adapter pattern that allows applications
 * to override the default behaviour for keeping track
 * of connected sockets in namespaces and rooms (and broadcasting to them)
 *
 */
interface {

	public void function namespaceBroadcast(
		  required string namespace
		, required string event
		, required array  rooms
		, required array  args
		,          string excludeSocket = ""
	);
	public void function socketBroadcast(
		  required string socketId
		, required string event
		, required array  args
		, required array  rooms
	);

	public void function registerSocket( required SocketIoSocket socket );
	public void function deregisterSocket( required string socketId );
	public void function joinRoom( required string socketId, required string roomName );
	public void function leaveRoom( required string socketId, required string roomName );
	public void function leaveAllRooms( required string socketId );
}