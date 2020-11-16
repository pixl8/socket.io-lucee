component {

	this.name = "socket.io-lucee test harness application";
	this.mappings[ "/socketiolucee" ] = ExpandPath( "/../../" );

	processingdirective preserveCase="true";

	public void function onRequest() output=true {
		_reloadCheck();

		include template="/index.cfm";
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
		var ns = io.of( "/admin" );

		ns.on( "connect", function( socket ){
			socket.send( "welcome", [ "Welcome to chat! This is just for you: #socket.getId()#" ] );
			socket.broadcast( "newmember", [ "Someone has joined the chat...#socket.getId()#" ] );
			socket.on( "clientEvent", function( message="nope" ) {
				Systemoutput( "onClientEvent: #SerializeJson( arguments.message )#" );
			} );
		} );

		application.io = io;
	}

}