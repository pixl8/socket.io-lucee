component {

	this.name = "socket.io-lucee test harness application";
	this.mappings[ "/socketiolucee" ] = ExpandPath( "/../../" );

	processingdirective preserveCase="true";

	public void function onRequest( required string requestedTemplate ) output=true {
		_reloadCheck();

		var io = application.io;

		include template=arguments.requestedTemplate;
	}

// private helpers
	private void function _reloadCheck() {
		if ( !StructKeyExists( application, "io" ) || ( url.fwreinit ?: "" ) == "true" ) {
			_setupServer();
		}
	}

	private void function _setupServer() {
		if ( StructKeyExists( application, "io" ) ) {
			application.io.close();
			StructDelete( application, "io" );
		}

		var io = new socketiolucee.models.SocketIoServer();
		var ns = io.sockets;

		ns.on( "connect", function( socket ){
			var params = socket.getHttpRequest().getRequestParams();
			var dummy = params.dummy ?: "";

			if ( dummy == "password" ) {
				socket.send( "welcome", [ "Welcome to chat! This is just for you: #socket.getId()#" ] );
				socket.joinRoom( "secure" );
				socket.broadcast( "newmember", "Someone has joined the chat...#socket.getId()#", "secure" );
				socket.on( "clientEvent", function( message="nope" ) {
					socket.broadcast( "echo", [ arguments.message ], [ "secure" ] );
				} );
			} else {
				socket.send( "denied", [ "Your name's not on the door, not coming in!" ] );
				socket.disconnect( false );
			}

		} );

		application.io = io;
	}

}