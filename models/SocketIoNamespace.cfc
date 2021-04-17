/**
 * Represends a Socket-IO Namespace.
 * Listen to the <code>on( "connect", callback )</code> event
 * to get a Socket and register specific listeners
 * for your connections. In addition, you can broadcast
 * messages to all socket connections in the namespace.
 *
 *
 */
component accessors=true {

	property name="name"     type="string";
	property name="ioserver" type="SocketIoServer";
	property name="executor" type="ISocketIoCallbackExecutor";

	variables._sockets = {};
	variables._eventHandlers = {};

// PUBLIC API
	/**
	 * Register a callback listener for the given event. Supported events are:<br>
	 * <ul>
	 * <li>connect</li>
	 * <li>disconnect</li>
	 * <li>disconnecting</li>
	 * </ul>
	 * All event callbacks will receive a socket object as their sole argument.
	 *
	 * @event.hint The name of the event (either 'connect', 'disconnect' or 'disconnecting')
	 * @callback.hint Closure function (or something else if using a custom executor) with logic to process the event
	 */
	public void function on( required string event, required any callback ) {
		variables._eventHandlers[ arguments.event ] = arguments.callback;
	}

	/**
	 * The broadcast method allows you to send an event to either:<br>
	 * <ul>
	 * <li>All connected sockets in the namespace</li>
	 * <li>All connected sockets in the provided room(s) within the namespace</li>
	 * </ul>
	 *
	 * @event.hint The name of the event to broadcast
	 * @args.hint Either a single argument, or array of arguments that the client event listener will receive
	 * @rooms.hint Either a single room name, or array of room names whose occupants will receive the event. If no rooms supplied, all connections to the namespace will receive the event.
	 */
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

	/**
	 * The getSocketCount method returns the number of connected sockets to this namespace
	 *
	 */
	public numeric function getSocketCount() {
		return StructCount( variables._sockets );
	}

// PROTECTED INTERNAL METHODS
	/**
	 * Internal method that deals with keeping track of sockets
	 * connected to this namespace.
	 *
	 */
	package SocketIoSocket function $registerSocket( required string socketId ) {
		if ( !StructKeyExists( variables._sockets, arguments.socketId ) ) {
			variables._sockets[ arguments.socketId ] = new SocketIoSocket(
				  id        = arguments.socketId
				, namespace = this
				, ioserver  = ioserver
				, executor  = executor
			);
		}

		return variables._sockets[ arguments.socketId ];
	}

	/**
	 * Internal helper method that allows us to get a socket object from
	 * a socket ID.
	 *
	 */
	package SocketIoSocket function $getSocket( required string socketId ) {
		return variables._sockets[ arguments.socketId ] ?: $registerSocket( arguments.socketId );
	}

	/**
	 * Internal helper method that deals with keeping track of sockets that
	 * have disconnected from the namespace.
	 *
	 */
	package void function $deRegisterSocket( required string socketId ) {
		StructDelete( variables._sockets, arguments.socketId );
	}

	/**
	 * Internal helper method that allows us to run event listener callbacks
	 * when we are asked to do so from the underlying java servlet.
	 *
	 */
	package void function $runEvent( required string event, required array args ) {
		if ( StructKeyExists( variables._eventHandlers, arguments.event ) ) {
			executor.execute(
				  callback  = _eventHandlers[ arguments.event ]
				, args      = arguments.args
				, namespace = this
			);
		}
	}

}