/**
 * Interface for callback executors. You would want to create your own implementation
 * here when the callback definition is something other than an inline
 * function with closure. For example, a Coldbox event name to run.
 *
 */
interface {
	/**
	 * The execute() method must be defined in implementing components
	 * to execute callback. Executes the given callback argument with the given
	 * argument array.
	 *
	 * @callback.hint  The registered callback for the event
	 * @args.hint      The arguments passed to the event
	 * @namespace.hint The namespace that the event was registered in (or that the socket belongs to)
	 * @socket.hint    Optional - socket on which the event is triggered
	 */
	public void function execute( required any callback, required array args, required any namespace, any socket );
}