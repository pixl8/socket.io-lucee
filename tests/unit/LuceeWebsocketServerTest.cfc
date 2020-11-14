component extends="testbox.system.BaseSpec"{

	function run(){
		var host = "127.0.0.1";
		var port = 3000;
		var websocketClient = new tests.util.WebsocketClient( "ws://#host#:#port#" );
		var dummyServerListener = new tests.resources.DummyListener();
		var websocketServer = new luceesocketio.models.server.LuceeWebsocketServer(
			  listener = dummyServerListener
			, host     = host
			, port     = port
		);

		describe( "registerBundle()", function(){
			it( "should register our OSGi bundle for our Java integration", function(){
				websocketServer.registerBundle();

				var failed = false;
				var message = "";
				try {
					CreateObject( "java", "com.pixl8.cfsocket.CfSocketServer", "com.pixl8.cfsocket" );
				} catch( any e ) {
					failed = true;
					message = e.message;
				}

				expect( failed ).toBeFalse( "Looks like our OSGi bundle failed to register. Lucee error: #message#" );
			} );
		} );

		describe( "start and stop server", function(){
			it( "should initialize our embedded undertow websocket server and accept connections", function(){
				websocketServer.startServer();
				websocketClient.testConnection();
				websocketServer.stopServer();

				var serverListenerDebug = dummyServerListener.getMemento();

				expect( ArrayLen( serverListenerDebug.connections ) ).toBe( 1 );
				expect( ArrayLen( serverListenerDebug.messages ) ).toBe( 2 );

				var connectionId = serverListenerDebug.connections[ 1 ].connectionId;
				expect( serverListenerDebug.messages[ 1 ] ).toBe( {
					  connectionId = connectionId
					, message      = "Hello"
				} );

				expect( serverListenerDebug.messages[ 2 ] ).toBe( {
					  connectionId = connectionId
					, message      = "Thanks for the conversation."
				} );

			} );
		} );

		try {
			websocketServer.stopServer();
		} catch( any e ){}
	}

}