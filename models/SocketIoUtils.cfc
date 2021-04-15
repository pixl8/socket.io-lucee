/**
 * Util helpers for our SocketIo system
 *
 */
component {

	/**
	 * The arrayToArgs method takes an array from the client
	 * and turns it into format ready for a Lucee UDF argument
	 * collection.
	 *
	 * @input.hint The raw Object[] from the java implementation
	 */
	public static any function arrayToArgs( required array input ) {
		var args = createObject( "java", "java.util.TreeMap" ).init();

		for( var i=1; i<=ArrayLen( arguments.input ); i++ ){
			args.put( JavaCast( "String", i ), static.javaTypeConverter( arguments.input[ i ] ) );
		}

		return args;
	}

	/**
	 * The javaTypeConverter method takes input from the java client
	 * and converts it into a format friendly for Lucee. i.e. a java JSONObject
	 * into a Lucee struct/array/whatever.
	 *
	 * @input.hint The raw object from the java implementation
	 */
	public static any function javaTypeConverter( required any input ) {
		if ( IsSimpleValue( arguments.input ) ) {
			return arguments.input;
		} else if ( IsInstanceOf( arguments.input, "org.json.JSONObject" ) ) {
			return DeserializeJson( arguments.input.toString() );
		} else if ( IsInstanceOf( arguments.input, "java.lang.Object" ) ) {
			var className = arguments.input.getClass().getName();

			if ( className contains "io.socket.socketio.server.SocketIoSocket$$Lambda" ) {
				var in = arguments.input;
				return function(){
					var args = [];
					for( arg in arguments ) {
						ArrayAppend( args, arguments[ arg ] );
					}
					in.sendAcknowledgement( JavaCast( "String[]", args ) );
				};
			}
		}

		return arguments.input;
	}

}