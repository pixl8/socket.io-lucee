component {

	this.name = "socket.io-lucee test harness application";
	this.mappings[ "/socketiolucee" ] = ExpandPath( "../../" );

	processingdirective preserveCase="true";

	public void function onRequest( required string requestedTemplate ) output=true {
		// each request, check to see if we need to setup our Server and listeners
		reloadCheck();

		include template=arguments.requestedTemplate;
	}

// private helpers
	private void function setupListeners() {
		var users    = application.users = [];
		var userMaps = application.userMaps = {};
		var io       = application.io;

		// note: this not thread safe - just a rough demo
		io.on( "connect", function( socket ){
			socket.on('setUsername', function( username ) {
				if( ArrayFindNoCase( users, username ) ) {
					socket.emit('userExists', username & ' username is taken! Try some other username.');
				} else {
					ArrayAppend( users, username );
					userMaps[ socket.getId() ] = username;
					socket.emit('userSet', username );
				}
			});

			socket.on('msg', function(msg) {
				io.sockets.emit('newmsg', msg);
			});

			socket.on('disconnect', function() {
				if ( Len( userMaps[ socket.getId() ] ?: "" ) ) {
					ArrayDelete( users, userMaps[ socket.getId() ] );
				}
			} );
		} );
	}

	private void function reloadCheck() {
		// Setup our server and listeners if either`?fwreinit=true` is
		// present in the URL, or if it has not yet been setup
		if ( !StructKeyExists( application, "io" ) || ( url.fwreinit ?: "" ) == "true" ) {
			shutdownServer();
			initServer();
			setupListeners();
		}
	}

	private void function initServer() {
		// create and start the server on default port, 3000
		application.io = new socketiolucee.models.SocketIoServer();
	}

	private void function shutdownServer() {
		if ( StructKeyExists( application, "io" ) ) {
			application.io.close();
			StructDelete( application, "io" );
		}

	}

}
