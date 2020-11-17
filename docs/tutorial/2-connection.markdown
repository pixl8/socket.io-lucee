---
layout: page
title: 2. Making a connection
nav_order: 2
parent: Tutorial
---

# 2. Making a connection

## Server side

Update your `Application.cfc` to the following:

```cfc
component {

	this.name = "socket.io-lucee test harness application";

	processingdirective preserveCase="true";

	public void function onRequest( required string requestedTemplate ) output=true {
		// each request, check to see if we need to setup our Server and listeners
		reloadCheck();

		include template=arguments.requestedTemplate;
	}

// private helpers
	private void function reloadCheck() {
		// Setup our server and listeners if either`?fwreinit=true` is 
		// present in the URL, or if it has not yet been setup
		if ( !StructKeyExists( application, "io" ) || ( url.fwreinit ?: "" ) == "true" ) {
			shutdownServer();
			initServer();
		}
	}

	private void function initServer() {
		// create and start the server on default port, 3000
		var io = new socketiolucee.models.SocketIoServer();
		
		// log socket connections and disconnections to the console
		io.on( "connect", function( socket ){
			SystemOutput( "A user connected..." );

			socket.on( "disconnect", function() {
				SystemOutput( "A user disconnected" );
			});
		} );

		application.io = io;
	}

	private void function shutdownServer() {
		if ( StructKeyExists( application, "io" ) ) {
			application.io.close();
			StructDelete( application, "io" );
		}

	}

}
```