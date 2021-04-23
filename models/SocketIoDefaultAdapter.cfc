/**
 * Default implementation of adapter. Uses local memory store
 * for keeping track of connected sockets to namespaces and rooms
 *
 */
component implements="ISocketIoAdapter" {

	variables._namespaces = {};
	variables._sockets = {};

	/**
	 * Broadcasts an event+args combination to
	 * all connected sockets in the namespace, optionally filtered
	 * by passed array of room names.
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
	) {
		var namespaceStore   = _getNamespaceStore( arguments.namespace );
		var socketsToReceive = {};

		if ( ArrayLen( rooms ) ) {
			for( var roomName in rooms ) {
				var roomStore = _getRoomStore( arguments.namespace, roomName );
				StructAppend( socketsToReceive, roomStore, false );
			}
		} else {
			socketsToReceive = namespaceStore.sockets;
		}

		for( var socketId in socketsToReceive ) {
			if ( socketId != arguments.excludeSocket ) {
				socketsToReceive[ socketId ].emit( arguments.event, Duplicate( arguments.args ) );
			}
		}
	}

	/**
	 * Broadcasts an event+args combination to
	 * all connected sockets in the given socket's namespace, optionally filtered
	 * by passed array of room names and *excluding the socket doing the broadcasting*.
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
	){
		if ( !StructKeyExists( variables._sockets, arguments.socketId ) ) {
			return;
		}

		return namespaceBroadcast(
			  namespace     = variables._sockets[ arguments.socketId ].socket.getNamespace().getName()
			, event         = arguments.event
			, rooms         = arguments.rooms
			, args          = arguments.args
			, excludeSocket = arguments.socketId
		);

	}

	/**
	 * Register a socket with the adapter.
	 *
	 * @socket SocketIoSocket object representing the connected socket
	 */
	public void function registerSocket( required SocketIoSocket socket ) {
		var ns = arguments.socket.getNamespace().getName();
		var id = arguments.socket.getId();

		variables._sockets[ id ] = {
			  ns     = ns
			, socket = arguments.socket
			, rooms  = []
		};

		var namespaceStore = _getNamespaceStore( ns );
		namespaceStore.sockets[ id ] = arguments.socket;
	}

	/**
	 * Deregister a socket from the adapter.
	 *
	 * @socketId The ID of the socket to forget
	 */
	public void function deregisterSocket( required string socketId ){
		var socketinfo = variables._sockets[ arguments.socketId ] ?: {};

		if ( StructCount( socketInfo ) ) {
			leaveAllRooms( arguments.socketId );
			var ns = socketinfo.socket.getNamespace().getName();
			var namespaceStore = _getNamespaceStore( ns );

			StructDelete( namespaceStore.sockets, arguments.socketId );
			StructDelete( variables._sockets, arguments.socketId );
		}
	}

	/**
	 * Registers the socket to a room.
	 *
	 * @socketId The ID of the socket to forget
	 * @roomName The name of the room to join
	 */
	public void function joinRoom( required string socketId, required string roomName ){
		var socketinfo = variables._sockets[ arguments.socketId ] ?: {};

		if ( StructCount( socketinfo ) ) {
			var ns = socketinfo.socket.getNamespace().getName();
			var namespaceStore = _getNamespaceStore( ns );
			var roomStore = _getRoomStore( ns, arguments.roomName );

			ArrayAppend( socketinfo.rooms, arguments.roomName );
			roomStore[ arguments.socketId ] = socketinfo.socket;
		}

	}

	/**
	 * Deregisters the socket from a room.
	 *
	 * @socketId The ID of the socket to forget
	 * @roomName The name of the room to join
	 */
	public void function leaveRoom( required string socketId, required string roomName ){
		var socketinfo = variables._sockets[ arguments.socketId ] ?: {};

		if ( StructCount( socketinfo ) ) {
			var ns = socketinfo.socket.getNamespace().getName();
			var namespaceStore = _getNamespaceStore( ns );
			var roomStore = _getRoomStore( ns, arguments.roomName );

			ArrayDeleteNoCase( socketinfo.rooms, arguments.roomName );
			StructDelete( roomStore, arguments.socketId );
		}
	}

	/**
	 * Deregisters the socket from all rooms.
	 *
	 * @socketId The ID of the socket to forget
	 */
	public void function leaveAllRooms( required string socketId ){
		var socketinfo = variables._sockets[ arguments.socketId ] ?: {};

		if ( StructCount( socketinfo ) ) {
			var ns = socketinfo.socket.getNamespace().getName();
			var namespaceStore = _getNamespaceStore( ns );
			for( var roomName in socketinfo.rooms ) {
				var roomStore = _getRoomStore( ns, roomName );
				StructDelete( roomStore, arguments.socketId );
			}
			socketinfo.rooms = [];
		}
	};

// PRIVATE HELPERS
	private struct function _getNamespaceStore( required string ns ) {
		if ( !StructKeyExists( variables._namespaces, ns ) ) {
			lock type="exclusive" name="socketio-ns-setup-lock-#arguments.ns#" timeout=1 {
				if ( !StructKeyExists( variables._namespaces, ns ) ) {
					variables._namespaces[ ns ] = {
						  sockets = {}
						, rooms = {}
					};
				}
			}
		}

		return variables._namespaces[ ns ] ?: {};
	}

	private struct function _getRoomStore( required string ns, required string roomName ) {
		var namespaceStore = _getNamespaceStore( ns );
		if ( !StructKeyExists( namespaceStore.rooms, arguments.roomName ) ) {
			lock type="exclusive" name="socketio-room-setup-lock-#arguments.ns#.#arguments.roomName#" timeout=1 {
				if ( !StructKeyExists( namespaceStore.rooms, arguments.roomName ) ) {
					namespaceStore.rooms[ arguments.roomName ] = {};
				}
			}
		}

		return namespaceStore.rooms[ arguments.roomName ] ?: {};
	}
}