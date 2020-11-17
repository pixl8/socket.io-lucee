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
  private void function setupListeners() {
    // we will use this method to setup our tutorial listeners, etc.
    var io = application.io;

    // log connections and disconnections
    io.on( "connect", function( socket ){
      SystemOutput( "A user connected..." );

      socket.on( "disconnect", function() {
        SystemOutput( "A user disconnected" );
      });
    } );
  }

  private void function reloadCheck() {
    // Setup our server and listeners if either`?fwreinit=true` is 
    // present in the URL, or if it has not yet been setup
    if ( !StructKeyExists( application, "io" ) || ( url.fwreinit ?: "" ) == "true" ) {
      shutdownServer();
      initServer();
      setupListeners();
    }
  }

  private void function initServer() {
    // create and start the server on default port, 3000
    application.io = new socketiolucee.models.SocketIoServer();
  }

  private void function shutdownServer() {
    if ( StructKeyExists( application, "io" ) ) {
      application.io.close();
      StructDelete( application, "io" );
    }

  }

}
```

## Client side

Update your HTML in `index.cfm` to the following listing:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    // making a connection to our Socket.io-Lucee server
    var socket = io( "127.0.0.1:3000" );
  </script>
</head>
<body>
</body>
</html>
```

Refresh your browser a few times. Now check your CommandBox server console output to see the logs of connections and disconnections to the server.

**Next:** [3. Event handling](3-eventhandling.html)
