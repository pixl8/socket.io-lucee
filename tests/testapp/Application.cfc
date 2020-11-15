component {

	this.name = "socket.io-lucee test harness application";
	this.mappings[ "/socketiolucee" ] = ExpandPath( "/../../" );

	processingdirective preserveCase="true";

	public void function onApplicationStart() {
		application.io = new socketiolucee.models.SocketIoServer();

		// io.of( "/dummynamespace" ).on( "connect", function(){} );
	}

}