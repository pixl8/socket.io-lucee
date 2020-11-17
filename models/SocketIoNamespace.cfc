component accessors=true extends="base.EventEmitter" {

	property name="name"     type="string";
	property name="ioserver" type="SocketIoServer";

	variables._sockets = {};

// PUBLIC API
	public void function broadcast(
		  required string event
		,          any    args  = []
		,          any    rooms = []
	) {
		ioserver.$broadcast( argumentCollection=arguments, namespace=name );
	}

	/**
	 * Alias of 'broadcast'
	 *
	 */
	public void function emit() { broadcast( argumentCollection=arguments ); }

// PROTECTED INTERNAL METHODS
	package SocketIoSocket function $registerSocket( required string socketId ) {
		if ( !StructKeyExists( variables._sockets, arguments.socketId ) ) {
			variables._sockets[ arguments.socketId ] = new SocketIoSocket(
				  id        = arguments.socketId
				, namespace = this
				, ioserver  = ioserver
			);
		}

		return variables._sockets[ arguments.socketId ];
	}

	package SocketIoSocket function $getSocket( required string socketId ) {
		return variables._sockets[ arguments.socketId ] ?: $registerSocket( arguments.socketId );
	}

	package void function $deRegisterSocket( required string socketId ) {
		StructDelete( variables._sockets, arguments.socketId );
	}

}