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

		io.of( "/admin" ).on( "connect", function( socketid ){
			SystemOutput( "we're connecting...#socketId#" );
		} );

		application.io = io;
	}

}