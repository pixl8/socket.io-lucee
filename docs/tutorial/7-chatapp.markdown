---
layout: page
title: 7. Chat application
nav_order: 7
parent: Tutorial
---

# 7. A demo chat application

The following is a listing for a super simple chat application. Update your code with the following and have a play! Note, the source code for this application has been taken and adapted from here: [https://www.tutorialspoint.com/socket.io/socket.io_chat_application.htm](https://www.tutorialspoint.com/socket.io/socket.io_chat_application.htm) (well worth going through their tutorial to get another angle).


```html
<!DOCTYPE html>
<html>
   <head>
     <title>Socket.io-Lucee: Tutorial (Chat demo)</title>
     <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
     <script>
      var socket = io( "127.0.0.1:3000" );
      function setUsername() {
       socket.emit('setUsername', document.getElementById('name').value);
      };
      var user;
      socket.on('userExists', function(data) {
       document.getElementById('error-container').innerHTML = data;
      });
      socket.on('userSet', function(username) {
       user = username;
       document.body.innerHTML = '<input type = "text" id = "message">\
       <button type = "button" name = "button" onclick = "sendMessage()">Send</button>\
       <div id = "message-container"></div>';
      });
      function sendMessage() {
       var msg = document.getElementById('message').value;
       if(msg) {
        socket.emit('msg', {message: msg, user: user});
       }
      }
      socket.on('newmsg', function(data) {
       if(user) {
        document.getElementById('message-container').innerHTML += '<div><b>' +
           data.user + '</b>: ' + data.message + '</div>'
       }
      })
     </script>
   </head>


   <body>
    <div id = "error-container"></div>
    <input id = "name" type = "text" name = "name" value = ""
     placeholder = "Enter your name!">
    <button type = "button" name = "button" onclick = "setUsername()">
     Let me chat!
    </button>
   </body>
</html>
```

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
    var users = application.users = [];
    var userMaps = application.userMaps = {};
    var io = application.io;

    // note: this not thread safe - just a rough demo

    io.on( "connect", function( socket ){
      socket.on('setUsername', function( username ) {
        if( ArrayFindNoCase( users, username ) ) {
          socket.emit('userExists', username & ' username is taken! Try some other username.');
        } else {
          ArrayAppend( users, username );
          userMaps[ socket.getId() ] = username;
          socket.emit('userSet', username );
        }
      });

      socket.on('msg', function(msg) {
        io.sockets.emit('newmsg', msg);
      });

      socket.on('disconnect', function() {
        if ( Len( userMaps[ socket.getId() ] ?: "" ) ) {
          ArrayDelete( users, userMaps[ socket.getId() ] );
        }
      } );
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

## Summary

The above listing demonstrates a few concepts. Have a play and make use of namespaces and rooms along the way.

Hopefully this gives you a broad understanding of the Socket.IO library and how to use it on both the client side and also from your Lucee applications with Socket.io-lucee.

