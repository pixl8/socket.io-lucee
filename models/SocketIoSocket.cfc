component accessors=true extends="base.EventEmitter" {

	property name="id"        type="string";
	property name="namespace" type="SocketIoNamespace";
	property name="ioserver"  type="SocketIoServer";

// PUBLIC API
	public void function on( required string event, required any action ) {
		super.on( argumentCollection=arguments );

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
		,          array  args  = []
		,          array  rooms = []
	) {
		ioserver.$broadcast( argumentCollection=arguments, socketId=id );
	}

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

}