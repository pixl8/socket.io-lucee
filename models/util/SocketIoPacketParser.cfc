component {

	variables._types = [
		  "CONNECT"
		, "DISCONNECT"
		, "EVENT"
		, "ACK"
		, "CONNECT_ERROR"
		, "BINARY_EVENT"
		, "BINARY_ACK"
	];

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	/**
	 * Parses socket.io packets into an easy to read
	 * struct with keys:
	 *
	 * * type: the message type
	 * * ns: the namespace
	 * * data: any data sent with the message
	 * * id: optional acknowledgment ID
	 *
	 * See https://github.com/socketio/socket.io-protocol#packet-format
	 * for documentation on this packet format
	 *
	 */
	public struct function parse( required string packet ) {
		// TODO, some validation of the input

		var parsed = {
			  type = _types[ Val( Left( Trim( arguments.packet ), 1 ) )+ 1 ]
			, data = {}
			, ns   = "/"
			, id   = ""
		};

		if ( Len( arguments.packet ) > 1 ) {
			var withoutType   = Right( arguments.packet, Len( arguments.packet )-1 );
			var jsonStart     = ReFind( "[\{\[]", withoutType )
			var preJson       = jsonStart == 1 ? "" : ( jsonStart ? ListFirst( withoutType, "{[" ) : withoutType );
			var potentialJson = jsonStart == 0 ? "" : Right( withoutType, Len( withoutType )-(jsonStart-1) );

			if ( Left( preJson, 1 ) == "/" ) {
				parsed.ns = ListFirst( preJson );
				parsed.id = ListRest( preJson );
			} else {
				parsed.id = preJson;
			}

			if ( IsJson( potentialJson ) ) {
				parsed.data = DeserializeJson( potentialJson );
			}
		}

		return parsed;
	}



}