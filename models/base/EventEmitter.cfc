component {

	variables._eventHandlers = {};

// PUBLIC API
	public void function on( required string event, required any action ) {
		variables._eventHandlers[ arguments.event ] = arguments.action;
	}

// FOR INTERNAL USE
	package void function $runEvent( required string event, required array args ) {
		if ( StructKeyExists( variables._eventHandlers, arguments.event ) ) {
			var orderedArgs = createObject( "java", "java.util.TreeMap" ).init();
			var index = 0;
			for( var arg in arguments.args ){
				orderedArgs.put( JavaCast( "String", ++index ), _convertArg( arg ) );
			}
			_eventHandlers[ arguments.event ]( argumentCollection=orderedArgs );
		}
	}

// PRIVATE HELPERS
	private any function _convertArg( required any arg ) {
		if ( IsSimpleValue( arguments.arg ) ) {
			return arg;
		} else if ( IsInstanceOf( arg, "org.json.JSONObject" ) ) {
			return DeserializeJson( arg.toString() );
		}

		return arg;
	}

}