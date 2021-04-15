---
layout: page
title: 7. Ack callbacks
nav_order: 7
parent: Tutorial
---

# 7. Acknowledgement (ACK) callbacks

In certain scenarios, you want to be able to receive direct acknowledgement receipts from the receiver of an event. This is true for both client to server events, and for server to client events. Socket.io-lucee lets you do this by supplying callback closures in Lucee.

## Server to client events

In your `Application.cfc`, change the `setupListeners` function to the listing below. Notice how we pass a third, anonymous function, argument to the `socket.emit` method:

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){

    socket.emit( "testack", [ "arg1", "arg2" ], function( result="" ){
      SystemOutput( "Received ACK back: #arguments.result#" );
    } );
    
  } );
}
```

Then, in your client logic, update to the following listing that listens for the incoming event and calls the callback argument (always the last argument to the event listener):

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000/admin" );

    socket.on( 'testack', function( a, b, callback ) {
      if ( a == "arg1" && b == "arg2" ) {
        callback( "acknowledged" );
      }
    });
  </script>
</head>
<body>
</body>
</html>
```

## Client to server events

Working the other way around, lets first update our HTML to fire off an event, supplying a callback function _as the last argument_:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000/admin" );

    socket.on( 'connect', function() {
      socket.emit( "testack", "arg1", "arg2", function( result ){
        document.write( result );
      } );
    });
  </script>
</head>
<body>
</body>
</html>
```

Finally, lets listen for that event in Lucee and respond using the callback arg (always the last argument):

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){

    socket.on( "testack", function( a, b, callback ){
      callback( "Received event from you! Thanks @ #Now()#" );
    } );
    
  } );
}
```

**Next:** [8. Chat application](8-chatapp.html)