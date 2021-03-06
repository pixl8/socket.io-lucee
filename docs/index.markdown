---
layout: home
title: Home
nav_order: 1
---

# Socket.io-lucee

**Socket.io-Lucee** is a [Socket.IO](https://socket.io/) server implementation for the [Lucee webserver](https://www.lucee.org). Socket.IO is a javascript library for realtime web applications. You can use the **Socket.io-lucee** project to marry your Lucee server with your frontend client(s) using the Socket.IO client library.

**The project is currently in an ALPHA state. This means it is suitable for experimenting with, but unlikely that it is ready for production use. We have implemented much of the core feature set, but there is much to do to ensure that we have a robust, performant and feature complete set.**

## A note on Socket.IO version compatibility

**Important note:** The project currently supports up to version `2.3.1` of the Socket.IO client. Version `3.0.0` has very recently been released (as of November 2020) and we will need to wait for downstream project updates before we can tackle the upgrade.

## Getting started

We recommend you follow the [installation guide](installing/) and [getting started tutorial](tutorial/). However, below is a super-brief outline of how you use the project:

### Lucee code

```cfc
// create and start the embdeed Socket.IO server
io = new socketiolucee.models.SocketIoServer();

// listen to default namespace connection events and send an event to any sockets that connect
io.on( "connect", function( socket ){
	socket.send( "Hello world from Lucee @ #Now()#" );
} );
```

### Frontend client

```html
<!DOCTYPE html>
<html>
<head>
	<title>Socket.io-Lucee: Hello world</title>
</head>
<body>
	<script src="http://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
	<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
	<script>
		// connect to our server
		var socket = io( "127.0.0.1:3000/" );

		// listen to the message event and output the message
		socket.on( 'message', function( message ){
			$( "#output" ).append( $( "<p>" + message + "</p>" ) );
		} );
	</script>
	<div id="output"></div>
</body>
```




