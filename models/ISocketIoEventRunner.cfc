/**
 * Interface for running events that have been triggered from the client.
 * You would want to create your own implementation
 * here when wanting to do something other than default manual .on() registration
 * of events with UDF callbacks
 *
 */
interface {
	/**
	 * The run() method must be defined in implementing components
	 * to execute the passed event.
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
	);
}