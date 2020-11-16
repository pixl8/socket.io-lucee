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
				orderedArgs.put( JavaCast( "String", ++index ), arg );
			}
			_eventHandlers[ arguments.event ]( argumentCollection=orderedArgs );
		}
	}

}