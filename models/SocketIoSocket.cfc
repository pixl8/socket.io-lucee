component accessors=true {

	property name="id"        type="string";
	property name="namespace" type="SocketIoNamespace";
	property name="ioserver"  type="SocketIoServer";

	variables._eventHandlers = {};

// PUBLIC API
	public void function on( required string event, required any action ) {
		variables._eventHandlers[ arguments.event ] = arguments.action;

		ioserver.$registerOn( namespace=namespace.getName(), socketId=id, event=arguments.event );
	}

	public void function send(
		  required string event
		,          array  args  = []
	) {
		ioserver.$send( argumentCollection=arguments, socketId=id );
	}

	public void function broadcast(
		  required string event
		,          any    args  = []
		,          any    rooms = []
	) {
		ioserver.$broadcast( argumentCollection=arguments, socketId=id );
	}

	/**
	 * Alias of 'broadcast'
	 *
	 */
	public void function emit() { broadcast( argumentCollection=arguments ); }

	public void function joinRoom( required string roomName ) {
		ioserver.$joinRoom( argumentCollection=arguments, socketId=id );
	}

	public void function leaveRoom( required string roomName ) {
		ioserver.$leaveRoom( argumentCollection=arguments, socketId=id );
	}

	public void function leaveAllRooms() {
		ioserver.$leaveAllRooms( socketId=id );
	}

	public void function disconnect( required boolean close ) {
		namespace.$deRegisterSocket( socketId=id );
		ioserver.$disconnect( socketId=id, close=arguments.close );
	}

// PROTECTED PACKAGE INTERNALS
	package void function $runEvent( required string event, required array args ) {
		if ( StructKeyExists( variables._eventHandlers, arguments.event ) ) {
			_eventHandlers[ arguments.event ](
				argumentCollection = SocketIoUtils::arrayToArgs( arguments.args )
			);
		}
	}

}