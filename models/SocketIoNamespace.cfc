component accessors=true {

	property name="name"   type="string";
	property name="server" type="SocketIoServer";

	variables._eventHandlers = {};

// PUBLIC API
	/**
	 * Register an event listener for this namespace. Valid
	 * namespace listeners are:
	 *
	 * * connect
	 *
	 */
	public void function on( required string event, required any action ) {
		variables._eventHandlers[ arguments.event ] = arguments.action;
	}

// FOR INTERNAL USE
	public void function runEvent( required string event, required array args ) {
		if ( StructKeyExists( variables._eventHandlers, arguments.event ) ) {
			_eventHandlers[ arguments.event ]( argumentCollection=args );
		}
	}

}