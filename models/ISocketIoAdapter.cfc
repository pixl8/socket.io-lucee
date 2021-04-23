/**
 * Interface for adapter pattern that allows applications
 * to override the default behaviour for keeping track
 * of connected sockets in namespaces and rooms (and broadcasting to them)
 *
 */
interface {

	/**
	 * Broadcasts an event+args combination to
	 * all connected sockets in the namespace, optionally filtered
	 * by passed array of room names. Implementing classes
	 * should call socket.emit( event, args ) for each matching socket.
	 *
	 *
	 * @namespace.hint     The ID of the namespace to broadcast to
	 * @event.hint         The name of the event
	 * @rooms.hint         Array of room names (can be empty for all rooms)
	 * @args.hint          Array of args to send with the event
	 * @excludeSocket.hint (Internal use) ID of socket to exclude from the broadcast. Used when proxied from socketBroadcast()
	 */
	public void function namespaceBroadcast(
		  required string namespace
		, required string event
		, required array  rooms
		, required array  args
		,          string excludeSocket = ""
	);

	/**
	 * Broadcasts an event+args combination to
	 * all connected sockets in the given socket's namespace, optionally filtered
	 * by passed array of room names and *excluding the socket broadcasting*. Implementing classes
	 * should get the namespace for the socket and, if found, proxy to namespaceBroadcast()
	 * and setting the excludeSocket argument to the socket ID
	 *
	 * @socketId.hint      The ID of the socket doing the broadcasting
	 * @event.hint         The name of the event
	 * @rooms.hint         Array of room names (can be empty for all rooms)
	 * @args.hint          Array of args to send with the event
	 */
	public void function socketBroadcast(
		  required string socketId
		, required string event
		, required array  args
		, required array  rooms
	);

	/**
	 * Register a socket with the adapter. Use this to track that the socket
	 * is connected.
	 *
	 * @socket SocketIoSocket object representing the connected socket
	 */
	public void function registerSocket( required SocketIoSocket socket );

	/**
	 * Deregister a socket from the adapter. Use this to track that the socket
	 * is no longer connected to any namespaces or rooms
	 *
	 * @socketId The ID of the socket to forget
	 */
	public void function deregisterSocket( required string socketId );

	/**
	 * Registers the socket to a room. Use this to track which sockets are connected to which rooms
	 *
	 * @socketId The ID of the socket to forget
	 * @roomName The name of the room to join
	 */
	public void function joinRoom( required string socketId, required string roomName );

	/**
	 * Deregisters the socket from a room. Use this to track which sockets are connected to which rooms
	 *
	 * @socketId The ID of the socket to forget
	 * @roomName The name of the room to join
	 */
	public void function leaveRoom( required string socketId, required string roomName );

	/**
	 * Deregisters the socket from all rooms. Use this to track which sockets are connected to which rooms
	 *
	 * @socketId The ID of the socket to forget
	 */
	public void function leaveAllRooms( required string socketId );
}