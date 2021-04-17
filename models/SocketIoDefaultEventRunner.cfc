/**
 * Default implementation of event runner.
 *
 */
component implements="ISocketIoEventRunner" {

	/**
	 * Default implementation of execute(). Assumes that
	 * the callback is registered and is an inline function that can be executed directly.
	 *
	 * @event.hint     The name of the event that was passed
	 * @args.hint      The arguments passed to the event
	 * @namespace.hint The namespace that the event was registered in (or that the socket belongs to)
	 * @listeners.hint Struct with keys that might match and values that are the unit to execute (e.g. a UDF)
	 * @socket.hint    Optional - socket on which the event is triggered
	 */
	public void function run(
		  required string event
		, required array  args
		, required any    namespace
		, required struct listeners
		,          any    socket
	){
		if ( StructKeyExists( arguments.listeners, arguments.event ) ) {
			arguments.listeners[ arguments.event ]( argumentCollection=SocketIoUtils::arrayToArgs( arguments.args ) );
		}
	}

}