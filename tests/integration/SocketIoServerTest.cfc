component extends="testbox.system.BaseSpec"{

	variables.port = 3000;

	function run(){
		describe( "socket.io-lucee server", function(){
			aroundEach( function( spec, suite ){
				var ioServerArgs = {
					  host  = "127.0.0.1"
					, port  = port
					, start = true
				};
				StructAppend( ioServerArgs, spec.data );

				variables.ioServer = new socketiolucee.models.SocketIoServer(
					argumentCollection = ioServerArgs
				);

				try {
					arguments.spec.body();
				} catch( any e ) {
					rethrow;
				} finally {
					variables.ioServer.shutdown();
				}
			} );

			it( "should report that it is running", function(){
				expect( ioServer.isRunning() ).toBe( true );
				expect( ArrayFind( [ "STARTED", "RUNNING" ], ioServer.getState() ) > 0 ).toBe( true );
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
				var joinedCount = { foo=0, bar=0 };
				var resultCheck = function(){
					if ( joinedCount.foo >= 2 && joinedCount.bar >= 2) {
						thread ioserver=ioserver name=CreateUUId() {
							attributes.ioServer.sockets.broadcast( "foo", [], [ "foo", "bar" ] );
						}
						sleep( 500 );
						break;
					}
				}

				variables.ioServer.on( "connect", function( socket ){
					socket.on( "join_foo", function(){
						joinedCount.foo++;
						socket.joinRoom( "foo" );
						resultCheck();
					} );
					socket.on( "join_bar", function(){
						joinedCount.bar++;
						socket.joinRoom( "bar" );
						resultCheck();
					} );
				} );

				var result = _execJs( "/tests/resources/js/test_broadcast_to_multiple_rooms.js" );
				expect( Trim( result ) ).toBe( "success" );

			} );

			it( "should broadcast from a socket to all other sockets", function(){
				var sockets = [];
				variables.ioServer.on( "connect", function( socket ){
					sockets.append( socket );

					socket.on( "foo", function(){
						if ( sockets.len() > 1 ) {
							thread ioserver=ioserver socket=sockets[ 1 ] name=CreateUUId() {
								attributes.socket.broadcast( "bar" );
								sleep( 500 );
							}
						}
					} );
				} );

				var result = _execJs( "/tests/resources/js/test_broadcast_to_all_clients_except_one.js" );
				expect( Trim( result ) ).toBe( "success" );
			} );

			it( "should respond to initial http request default with ping interval and ping timeout", function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10;

				var response = DeserializeJson( ReReplace( httpResult.fileContent, "^[0-9]+:[0-9]+", "" ) );

				expect( response.pingInterval ).toBe( 5000 );
				expect( response.pingTimeout ).toBe( 25000 );
			} );

			it( title="should respond to initial http request with custom configured ping interval and ping timeout", body=function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10 {
					httpparam name="Origin" type="header" value="localhost";
				}
				var response = DeserializeJson( ReReplace( httpResult.fileContent, "^[0-9]+:[0-9]+", "" ) );

				expect( response.pingInterval ).toBe( 10000 );
				expect( response.pingTimeout ).toBe( 2000 );
			}, data={ pingInterval=10000, pingTimeout=2000 } );

			it( "should respond to initial http request with no CORS headers by default", function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10 {
					httpparam name="Origin" type="header" value="localhost";
				}
				expect( StructKeyExists( httpResult.responseheader, "Access-Control-Allow-Origin" ) ).toBeFalse();
			} );


			it( title="should respond to initial http request with CORS headers when cors handling is enabled", body=function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10 {
					httpparam name="Origin" type="header" value="localhost";
				}
				expect( httpResult.responseheader[ "Access-Control-Allow-Origin" ] ?: "" ).toBe( "localhost" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Methods" ] ?: "" ).toBe( "GET,HEAD,PUT,PATCH,POST,DELETE" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Credentials" ] ?: "" ).toBe( "true" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Headers" ] ?: "" ).toBe( "origin, content-type, accept" );
			}, data={ enableCorsHandling=true } );

			it( title="should not respond to initial http request with CORS headers when cors handling is enabled but the origin is not one of specifically configured origins", body=function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10 {
					httpparam name="Origin" type="header" value="localhost";
				}
				expect( StructKeyExists( httpResult.responseheader, "Access-Control-Allow-Origin" ) ).toBeFalse();
			}, data={ enableCorsHandling=true, allowedCorsOrigins=[ "127.0.0.1" ] } );

			it( title="should respond to initial http request with CORS headers when cors handling is enabled and the supplied origin matches the specifically configured origins", body=function(){
				var httpResult = "";
				http url="http://127.0.0.1:3000/socket.io/?transport=polling" result="httpResult" timeout=10 {
					httpparam name="Origin" type="header" value="localhost";
				}
				expect( httpResult.responseheader[ "Access-Control-Allow-Origin" ] ?: "" ).toBe( "localhost" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Methods" ] ?: "" ).toBe( "GET,HEAD,PUT,PATCH,POST,DELETE" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Credentials" ] ?: "" ).toBe( "true" );
				expect( httpResult.responseheader[ "Access-Control-Allow-Headers" ] ?: "" ).toBe( "origin, content-type, accept" );
			}, data={ enableCorsHandling=true, allowedCorsOrigins=[ "127.0.0.1", "localhost" ] } );

			it( "should receive and process ack responses from clients receiving messages", function(){
				var result = { arg="not received" };

				variables.ioServer.on( "connect", function( socket ){

					thread socket=arguments.socket name=CreateUUId() result=result {
						sleep( 100 );
						attributes.socket.emit( "foo", "bar", function( arg="something else" ){
							result.arg = arguments.arg;
						} );
					}
				} );

				_execJs( "/tests/resources/js/test_message_to_client_nonbinary_ack.js" );
				expect( result.arg ).toBe( "baz" );
			} );

			it( "should send back an ack to client when asked for", function(){
				variables.ioServer.on( "connect", function( socket ){
					socket.on( "foo", function( arg1, arg2, callback ){
						callback( "baz" );
					} );
				} );

				var result =_execJs( "/tests/resources/js/test_message_to_server_nonbinary_ack" );
				expect( Trim( result ) ).toBe( "baz" );
			} );


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
		try {
			return tests.utils.JsRunner::executeScript( arguments.jsPath, port )
		} catch( any e ) {
			fail( e.message & ". " & ( e.detail ?: "" ) );
		}
	}

}