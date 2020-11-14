component extends="testbox.system.BaseSpec"{

	function run(){
		var websocketServer = new luceesocketio.models.LuceeWebsocketServer();

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
	}

}