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
	 */
	public void function execute( required any callback, required array args ) {
		arguments.callback( argumentCollection=SocketIoUtils::arrayToArgs( arguments.args ) );
	}

}