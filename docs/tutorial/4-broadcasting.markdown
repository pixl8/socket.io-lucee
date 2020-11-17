---
layout: page
title: 4. Broadcasting
nav_order: 4
parent: Tutorial
---

# 4. Broadcasting

Broadcasting means sending a message to all connected clients. Broadcasting can be done at multiple levels. We can broadcast to:

* all clients on a namespace 
* clients in particular room(s) within a namespace

> _Note: More on namespaces and rooms later._

## Broadcast to everyone on the default namespace

So far, we have been making use of the default namespace - let's continue to do that and broadcast a message to all connected clients on the default namespace. In your `Application.cfc`:

```cfc
private void function setupListeners() {
  var io = application.io;

  application.clientCount = 0;

  io.on( "connect", function( socket ){
    application.clientCount++;
    io.sockets.emit( 'clientAlert', { description='#application.clientCount# clients connected!' });

    socket.on( "disconnect", function() {
      application.clientCount--;
      io.sockets.emit( 'clientAlert', { description='#application.clientCount# clients connected!' });
    });
  } );
}
```

On the client side, we just need to handle the broadcast event:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.on( 'clientAlert', function( data ) {
      document.body.innerHTML = '';
      document.write( data.description );
    });
  </script>
</head>
<body>
</body>
</html>
```

Reload the application and open multiple browser windows to the homepage. See the connected client count update in all windows as you open and close windows.

## Broadcasting to everyone but the current connection

We just sent a message to everyone on the same namespace. In our next example, we will broadcast to everyone _except for the user inititing the broadcast_. For this, we will make use of `socket.broadCast()`:

```cfc
private void function setupListeners() {
  var io = application.io;

  application.clientCount = 0;

  io.on( "connect", function( socket ){
    application.clientCount++;
    
    socket.send( "Hey, welcome to the namespace!" );
    socket.broadcast( 'clientAlert', { description='#application.clientCount# clients connected!' });

    socket.on( "disconnect", function() {
      application.clientCount--;
      socket.broadcast( 'clientAlert', { description='#application.clientCount# clients connected!' });
    });
  } );
}
```

Make sure we handle our new welcome `message` event in the client side:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.on( 'clientAlert', function( data ) {
      document.body.innerHTML = '';
      document.write( data.description );
    });

    socket.on( 'message', function( msg ) {
      document.body.innerHTML = '';
      document.write( msg );
    });
  </script>
</head>
<body>
</body>
</html>
```

Reload the application and repeat the experiment from before. Notice now how the new client gets the welcome message while existing clients get the client connected count.