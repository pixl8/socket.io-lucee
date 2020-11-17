---
layout: page
title: 5. Namespaces
nav_order: 5
parent: Tutorial
---

# 5. Namespaces

Socket.IO servers allow you to organise your connections into **namespaces**. This allows convenient separation of application logic without the need to spin up multiple different servers. Single client connections can be connected to multiple namespaces from within the same browser session, using only a single TCP connection.

Namespaces are created from the server side (i.e. in our Lucee code). On the client side, we specify the namespace we wish to connect to in the `io()` constructor.

## Custom namespaces

To create a custom namespace, we call `io.of( namespace )` method on the server side to register and get the namespace. From there, we can begin listening to events:

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){
    socket.send( "Welcome to the admin namespace...!" );
  } );
}
```

To connect a client to this namespace, will append the namespace to our server address:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000/admin" );

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

Try it out. Clients should receive a welcome message from the admin namespace.

## About default namespaces

Until now, we have been making use of the **default namespace**. This namespace can also be referred to as `"/"`.

### Connecting from the client

```js
var socket = io(); // using the current domain and port (see hosting guide)
// or this:
var socket = io( "mysite.com:3000" );
```

### Server side shortcuts

On the server side we have been making use of `io.on( event, callback )` and `io.sockets.emit( event, data )`. These are really just aliases to methods on the namespace object:

```cfc
// io.sockets is alias of
io.of( "/" );

// io.on( event, callback ) is alias of
io.of( "/" ).on( event, callback );
```

**Next:** [6. Rooms](6-rooms.html)