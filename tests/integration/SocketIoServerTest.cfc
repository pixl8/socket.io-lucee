component extends="testbox.system.BaseSpec"{

	variables.port = 3000;

	function beforeAll(){
 		variables.ioServer = new socketiolucee.models.SocketIoServer(
			  host  = "127.0.0.1"
			, port  = port
			, start = true
		);
	}
    function afterAll(){
		variables.ioServer.shutdown();
    }

	function run(){
		describe( "socket.io client", function(){
			it( "should successfully connect to our server", function(){
				var result = _execJs( "/tests/resources/js/test_connect.js" );

				expect( Trim( result ) ).toBe( "connect success" );
			} );
		} );

		// describe( "connect_dynamic", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_server_nonbinary_noack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_client_nonbinary_noack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_server_nonbinary_ack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_client_nonbinary_ack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_server_binary_noack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "message_to_client_binary_noack", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "broadcast_to_all_clients", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "broadcast_to_one_room", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "broadcast_to_multiple_rooms", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );
		// describe( "broadcast_to_all_clients_except_one", function(){
		// 	it( "should work...", function(){
		// 		// fail( "but we haven't implemented this test yet" );
		// 	} );
		// } );

	}

	private string function _execJs( required string jsPath ) {
		return tests.utils.JsRunner::executeScript( arguments.jsPath, port )
	}

}