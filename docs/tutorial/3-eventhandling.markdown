---
layout: page
title: 3. Event handling
nav_order: 3
parent: Tutorial
---

# 3. Event handling

Socket.IO connection communication is all centered around events. There are a number of reserved system events such as `connect`, `disconnect`, `disconnecting` and `message`. In addition, programs can fire off and listen for arbitrary events that are specific to the application.

## A simple message event

Let's fire off a `message` event from the server side. Modify your `Application.cfc$setupListeners()` method:

```cfc
private void function setupListeners() {
  var io = application.io;

  io.on( "connect", function( socket ){
    SystemOutput( "A user connected..." );

    socket.on( "disconnect", function() {
      SystemOutput( "A user disconnected" );
    });

    // we're using a bg thread + sleep() here to fake
    // an example of a later event
    thread socket=socket name="bg-thrd-#socket.getId()#" {
      sleep( 4000 );
      socket.send( "Sent a message 4 seconds after connection!" );
    }
  } );
}
```

Then listen for the event on the client (`index.cfm`):

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.on('message', function(data){document.write(data)});
  </script>
</head>
<body>
</body>
```

Try it out in your browser. You will need to add `?fwreinit=true` in the URL for the first hit to have our Lucee application run through the changes.

## Custom events

The `message` event has limited use. In a real application we will want to differentiate between different events to control behaviour.

Socket.IO allows us to fire off custom events. To do this from the server, we will use `socket.emit( eventName, args )`:

```cfc
private void function setupListeners() {
  var io = application.io;

  io.on( "connect", function( socket ){
    SystemOutput( "A user connected..." );

    socket.on( "disconnect", function() {
      SystemOutput( "A user disconnected" );
    });

    thread socket=socket name="bg-thrd-#socket.getId()#" {
      sleep( 4000 );

      // use socket.emit() for custom events direct to a socket
      socket.emit( "testEvent", "Sent a testEvent 4 seconds after connection!" );
    }
  } );
}
```


```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.on('testEvent', function(data){document.write(data)});
  </script>
</head>
<body>
</body>
```

Reload the application and try it out in your browser.

## Client to server events

We can also use `socket.emit()` from the client side to send messages to the server:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.emit('clientEvent', 'Hello from the client');
  </script>
</head>
<body>
</body>
```

Use `socket.on()` to listen to the event from the server side:

```cfc
private void function setupListeners() {
  var io = application.io;

  io.on( "connect", function( socket ){
    SystemOutput( "A user connected..." );

    socket.on( "disconnect", function() {
      SystemOutput( "A user disconnected" );
    });

    socket.on( "clientEvent", function( msg ) {
      SystemOutput( "Client event received: " & arguments.msg );
    });    
  } );
}
```

Reload the application and watch your CommanxBox console logs for messages from the client.

**Next:** [4. Broadcasting](4-broadcasting.html)