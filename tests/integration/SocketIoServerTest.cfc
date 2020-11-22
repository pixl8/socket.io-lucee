component extends="testbox.system.BaseSpec"{

	variables.port = 3000;




	function run(){
		describe( "socket.io-lucee server", function(){
			aroundEach( function( spec, suite ){
				variables.ioServer = new socketiolucee.models.SocketIoServer(
					  host  = "127.0.0.1"
					, port  = port
					, start = true
				);

				try {
					arguments.spec.body();
				} catch( any e ) {
					rethrow;
				} finally {
					variables.ioServer.shutdown();
				}
			} );

			it( "should allow connections from clients", function(){
				var result = _execJs( "/tests/resources/js/test_connect.js" );

				expect( Trim( result ) ).toBe( "connect success" );
			} );

			it( "should receive events from clients", function(){
				var received = [];

				variables.ioServer.on( "connect", function( socket ){
					socket.on( "foo", function( arg1, arg2 ){
						received.append({ arg1=arguments.arg1 ?: "", arg2=arguments.arg2 ?: "" } );
					} );
				} );

				_execJs( "/tests/resources/js/test_message_to_server_nonbinary_noack.js" );

				expect( received ).toBe( [{ arg1=1, arg2="bar" } ] );
			} );

			it( "should be able to send messages to connected clients", function(){
				variables.ioServer.on( "connect", function( socket ){
					socket.emit( "foo", "bar" );
				} );

				var result = _execJs( "/tests/resources/js/test_message_to_client_nonbinary_noack.js" );
				expect( Trim( result ) ).toBe( "message received" );

			} );

			it( "should allow broadcasting to all connected clients in a namespace", function(){
				var connected = 0;

				variables.ioServer.on( "connect", function(){

					if ( ++connected >= 2 ) {
						sleep( 100 );
						variables.ioServer.sockets.broadcast( "foo" );
					}

				} );

				var result = _execJs( "/tests/resources/js/test_broadcast_to_all_clients.js" );
				expect( Trim( result ) ).toBe( "messages received" );

			} );

			it( "should allow broadcasting to a single room in a namespace", function(){
				var connected = 0;
				var inroom = 0;

				variables.ioServer.on( "connect", function( socket ){
					connected++;
					socket.on( "join", function(){
						socket.joinRoom( "testroom" );
						if ( ++inroom >= 2 ) {
							variables.ioServer.sockets.broadcast( "foo", [], "testroom" );
						}
					} );
				} );

				var result = _execJs( "/tests/resources/js/test_broadcast_to_one_room.js" );
				expect( Trim( result ) ).toBe( "success" );

			} );

			it( "should allow broadcasting to multiple rooms in a namespace", function(){
				variables.ioServer.on( "connect", function( socket ){
					socket.on( "join_foo", function(){
						socket.joinRoom( "foo" );
					} );
					socket.on( "join_bar", function(){
						socket.joinRoom( "bar" );
					} );
				} );

				thread ioserver=ioserver name=CreateUUId() {
					sleep( 500 );
					attributes.ioServer.sockets.broadcast( "foo", [], [ "foo", "bar" ] );
				}

				var result = _execJs( "/tests/resources/js/test_broadcast_to_multiple_rooms.js" );
				expect( Trim( result ) ).toBe( "success" );

			} );

			it( "should broadcast from a socket to all other sockets", function(){
				var sockets = [];
				variables.ioServer.on( "connect", function( socket ){
					sockets.append( socket );

					socket.on( "foo", function(){
						if ( sockets.len() > 1 ) {
							sockets[1].broadcast( "bar" );
						}
					} );
				} );

				var result = _execJs( "/tests/resources/js/test_broadcast_to_all_clients_except_one.js" );
				expect( Trim( result ) ).toBe( "success" );
			} );

			// it( "should send back an ack to client when asked for", function(){
			// 	fail( "but not yet implemented" );
			// } );

			// it( "should receive and process ack responses from clients receiving messages", function(){
			// 	fail( "but not yet implemented" );
			// } );

			// it( "should allow client connections to dynamic namespaces", function(){
			// 	fail( "but we don't currently support dynamic namespace names in our server." );
			// } );

			// it( "should allow sending binary data to clients", function(){
			// 	fail( "but not yet implemented" );
			// } );

			// it( "should allow receiving of binary data from clients", function(){
			// 	fail( "but not yet implemented" );
			// } );
		} );
	}

	private string function _execJs( required string jsPath ) {
		return tests.utils.JsRunner::executeScript( arguments.jsPath, port )
	}

}