component extends="testbox.system.BaseSpec"{

	function run(){

		var parser = new luceesocketio.models.util.SocketIoPacketParser();

		describe( "parse()", function(){

			it( "Should parse a socketio packet for disconnecting from the main namespace", function(){
				expect( parser.parse( "1" ) ).toBe( {
					  type = "DISCONNECT"
					, ns   = "/"
					, data = {}
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for disconnecting from a non-default namespace", function(){
				expect( parser.parse( "1/admin," ) ).toBe( {
					  type = "DISCONNECT"
					, ns   = "/admin"
					, data = {}
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for connection to the default namespace without any data", function(){
				expect( parser.parse( "0" ) ).toBe( {
					  type = "CONNECT"
					, ns   = "/"
					, data = {}
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for connection to a non-default namespace without any data", function(){
				expect( parser.parse( "0/admin," ) ).toBe( {
					  type = "CONNECT"
					, ns   = "/admin"
					, data = {}
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for connection to the default namespace with data", function(){
				expect( parser.parse( "0{ ""token"":""test""}" ) ).toBe( {
					  type = "CONNECT"
					, ns   = "/"
					, data = { token="test" }
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for connection to a non-default namespace with data", function(){
				expect( parser.parse( "0/admin,{ ""token"":""test""}" ) ).toBe( {
					  type = "CONNECT"
					, ns   = "/admin"
					, data = { token="test" }
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for event sending to the default namespace with data", function(){
				expect( parser.parse( "2[""hello"",1]" ) ).toBe( {
					  type = "EVENT"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for event sending to the default namespace with an ack ID and data", function(){
				expect( parser.parse( "259468[""hello"",1]" ) ).toBe( {
					  type = "EVENT"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = 59468
				} );
			} );

			it( "Should parse a socketio packet for event sending to a non-default namespace with an ack ID and data", function(){
				expect( parser.parse( "2/admin,59468[""hello"",1]" ) ).toBe( {
					  type = "EVENT"
					, ns   = "/admin"
					, data = [ "hello", 1 ]
					, id   = 59468
				} );
			} );

			it( "Should parse a socketio packet for ack sending to the default namespace with data", function(){
				expect( parser.parse( "3[""hello"",1]" ) ).toBe( {
					  type = "ACK"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = ""
				} );
			} );

			it( "Should parse a socketio packet for ack sending to the default namespace with an ack ID and data", function(){
				expect( parser.parse( "359468[""hello"",1]" ) ).toBe( {
					  type = "ACK"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = 59468
				} );
			} );

			it( "Should parse a socketio packet for ack sending to a non-default namespace with an ack ID and data", function(){
				expect( parser.parse( "3/admin,59468[""hello"",1]" ) ).toBe( {
					  type = "ACK"
					, ns   = "/admin"
					, data = [ "hello", 1 ]
					, id   = 59468
				} );
			} );

		} );

		describe( "serialize()", function() {
			it( "Should serialize a socketio struct to a packet for disconnecting from the main namespace", function(){
				expect( parser.serialize( {
					  type = "DISCONNECT"
					, ns   = "/"
					, data = {}
					, id   = ""
				} ) ).toBe( "1" );
			} );

			it( "Should serialize a socketio struct to a packet for disconnecting from a non-default namespace", function(){
				expect( parser.serialize( {
					  type = "DISCONNECT"
					, ns   = "/admin"
					, data = {}
					, id   = ""
				} ) ).toBe( "1/admin," );
			} );

			it( "Should serialize a socketio struct to a packet for connection to the default namespace without any data", function(){
				expect( parser.serialize( {
					  type = "CONNECT"
					, ns   = "/"
					, data = {}
					, id   = ""
				} ) ).toBe( "0" );
			} );

			it( "Should serialize a socketio struct to a packet for connection to a non-default namespace without any data", function(){
				expect( parser.serialize( {
					  type = "CONNECT"
					, ns   = "/admin"
					, data = {}
					, id   = ""
				} ) ).toBe( "0/admin," );
			} );

			it( "Should serialize a socketio struct to a packet for connection to the default namespace with data", function(){
				expect( parser.serialize( {
					  type = "CONNECT"
					, ns   = "/"
					, data = { token="test" }
					, id   = ""
				}) ).toBe( "0{""token"":""test""}" );
			} );

			it( "Should serialize a socketio struct to a packet for connection to a non-default namespace with data", function(){
				expect( parser.serialize( {
					  type = "CONNECT"
					, ns   = "/admin"
					, data = { token="test" }
					, id   = ""
				} ) ).toBe( "0/admin,{""token"":""test""}" );
			} );

			it( "Should serialize a socketio struct to a packet for event sending to the default namespace with data", function(){
				expect( parser.serialize( {
					  type = "EVENT"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = ""
				} ) ).toBe( "2[""hello"",1]" );
			} );

			it( "Should serialize a socketio struct to a packet for event sending to the default namespace with an ack ID and data", function(){
				expect( parser.serialize( {
					  type = "EVENT"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = 59468
				} ) ).toBe( "259468[""hello"",1]" );
			} );

			it( "Should serialize a socketio struct to a packet for event sending to a non-default namespace with an ack ID and data", function(){
				expect( parser.serialize( {
					  type = "EVENT"
					, ns   = "/admin"
					, data = [ "hello", 1 ]
					, id   = 59468
				} ) ).toBe( "2/admin,59468[""hello"",1]" );
			} );

			it( "Should serialize a socketio struct to a packet for ack sending to the default namespace with data", function(){
				expect( parser.serialize( {
					  type = "ACK"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = ""
				} ) ).toBe( "3[""hello"",1]" );
			} );

			it( "Should serialize a socketio struct to a packet for ack sending to the default namespace with an ack ID and data", function(){
				expect( parser.serialize( {
					  type = "ACK"
					, ns   = "/"
					, data = [ "hello", 1 ]
					, id   = 59468
				} ) ).toBe( "359468[""hello"",1]" );
			} );

			it( "Should serialize a socketio struct to a packet for ack sending to a non-default namespace with an ack ID and data", function(){
				expect( parser.serialize( {
					  type = "ACK"
					, ns   = "/admin"
					, data = [ "hello", 1 ]
					, id   = 59468
				} ) ).toBe( "3/admin,59468[""hello"",1]" );
			} );
		} );

	}
}