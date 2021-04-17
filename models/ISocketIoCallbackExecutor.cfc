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
	 */
	public void function execute( required any callback, required array args );
}