/**
 * Default implementation of callback execution. Expects all
 * callback definitions to be inline functions and
 *
 */
component implements="ISocketIoCallbackExecutor" {

	/**
	 * Default implementation of execute(). Assumes that
	 * the callback is an inline function that can be
	 * executed directly.
	 *
	 * @callback.hint  The registered callback for the event
	 * @args.hint      The arguments passed to the event
	 * @namespace.hint The namespace that the event was registered in (or that the socket belongs to)
	 * @socket.hint    Optional - socket on which the event is triggered
	 */
	public void function execute(
		  required any   callback
		, required array args
		, required any   namespace
		,          any   socket
	) {
		arguments.callback( argumentCollection=SocketIoUtils::arrayToArgs( arguments.args ) );
	}

}