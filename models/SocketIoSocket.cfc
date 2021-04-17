/**
 * Represents a single socket connection.
 * The socket object can be used to send direct
 * messages, to join/leave rooms and to broadcast
 * to other sockets within the namespace and optional
 * rooms.
 *
 */
component accessors=true {

	property name="id"          type="string"                    hint="The ID of the socket, as provided by our underlying embedded java servlet.";
	property name="namespace"   type="SocketIoNamespace"         hint="The namespace to which the socket is connected.";
	property name="ioserver"    type="SocketIoServer"            hint="The SocketIoServer object in which the socket and namespace exist.";
	property name="httpRequest" type="SocketIoRequest"           hint="The original HTTP request that triggered the socket connection. Useful for getting information for authentication and other delegating logic.";
	property name="executor"    type="ISocketIoCallbackExecutor" hint="Implementation for executing registered callbacks on the socket";

	variables._eventHandlers = {};
	variables._ackCallbacks = {};

// PUBLIC API
	/**
	 * Register an incoming event listener from the connected socket.
	 *
	 * @event.hint The name of the event to listen to.
	 * @callback.hint Closure UDF (or something else if using custom executor) with logic to process the event. Receives positional arguments that were sent by the client.
	 */
	public void function on( required string event, required any callback ) {
		variables._eventHandlers[ arguments.event ] = arguments.callback;

		ioserver.$registerOn( namespace=namespace.getName(), socketId=id, event=arguments.event );
	}

	/**
	 * Sends a direct event to the connected client.
	 *
	 * @event.hint       The name of the event to send.
	 * @args.hint        Single argument, or array of arguments to send to any registered client listener functions for this event.
	 * @ackCallback.hint Closure function that will receive ack confirmation of message receipt
	 */
	public void function emit(
		  required string event
		,          any    args = []
		,          any    ackCallback
	) {
		if ( StructKeyExists( arguments, "ackCallback" ) ) {
			var ackId = CreateUUId();
			variables._ackCallbacks[ ackId ] = arguments.ackCallback;
		}
		ioserver.$send(
			  argumentCollection = arguments
			, namespace          = namespace.getName()
			, socketId           = id
			, ackId              = ackId ?: ""
		);
	}

	/**
	 * Sends a direct message event to the connected client with the provided string message.
	 *
	 * @message.hint The message to send.
	 */
	public void function send( required string message ) {
		ioserver.$send(
			  event     = "message"
			, args      = [ arguments.message ]
		 	, socketId  = id
		 	, namespace = namespace.getName()
		 );
	}

	/**
	 * Broadcasts an event to all connected clients to the
	 * same namespace and optional room(s) <strong>excluding this socket connection</strong>.
	 *
	 * @event.hint The name of the event to broadcast.
	 * @args.hint Either a single argument, or array of arguments to send to the connected clients.
	 * @args.hint Optional room name, or array of room names, to send the event to.
	 *
	 */
	public void function broadcast(
		  required string event
		,          any    args  = []
		,          any    rooms = []
	) {
		ioserver.$broadcast( argumentCollection=arguments, socketId=id );
	}

	/**
	 * Registers the connected client to the given room name.
	 *
	 * @roomName.hint The name of the room
	 *
	 */
	public void function joinRoom( required string roomName ) {
		ioserver.$joinRoom( argumentCollection=arguments, socketId=id );
	}

	/**
	 * Unregisters the connected client from the given room name.
	 *
	 * @roomName.hint The name of the room
	 *
	 */
	public void function leaveRoom( required string roomName ) {
		ioserver.$leaveRoom( argumentCollection=arguments, socketId=id );
	}

	/**
	 * Unregisters the connected client from all rooms.
	 *
	 */
	public void function leaveAllRooms() {
		ioserver.$leaveAllRooms( socketId=id );
	}

	/**
	 * Disconnects the connected client from the namespace.
	 *
	 * @close.hint If true, also closes the underlying socket connection.
	 *
	 */
	public void function disconnect( required boolean close ) {
		namespace.$deRegisterSocket( socketId=id );
		ioserver.$disconnect( socketId=id, close=arguments.close );
	}

// PROTECTED PACKAGE INTERNALS
	/**
	 * Internal helper method that allows us to run event listener callbacks
	 * when we are asked to do so from the underlying java servlet.
	 *
	 */
	package void function $runEvent( required string event, required array args ) {
		if ( StructKeyExists( variables._eventHandlers, arguments.event ) ) {
			executor.execute(
				  callback  = variables._eventHandlers[ arguments.event ]
				, args      = arguments.args
				, namespace = namespace
				, socket    = this
			);
		}
	}

	/**
	 * Internal helper method that allows us to run ack callbacks
	 * when we are asked to do so from the underlying java servlet.
	 *
	 */
	package void function $runAckCallback( required string ackId, required array args ) {
		if ( StructKeyExists( variables._ackCallbacks, arguments.ackId ) ) {
			executor.execute(
				  callback  = variables._ackCallbacks[ arguments.ackId ]
				, args      = arguments.args
				, namespace = namespace
				, socket    = this
			);

			StructDelete( variables._ackCallbacks, arguments.ackId );
		}
	}

}