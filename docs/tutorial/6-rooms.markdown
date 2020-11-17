---
layout: page
title: 6. Rooms
nav_order: 6
parent: Tutorial
---

# 6. Rooms

You can further segregate your connected sockets into abritary _rooms_. 

Room creation and the adding/removing of clients to and from those rooms is all controlled from the **server side**. It is also up to the server to inform the client that they have been added to a room (if that is indeed necessary). The client otherwise has no notion of rooms (_NOTE: need to verify this assertion_.).

## Joining rooms

Joining a room is as simple as `socket.joinRoom( roomName )`. In the example below, we join "super-cool-gang" room. In a real world example, it is just as likely that the room name will be dynamic based on some other logic.

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){

    socket.joinRoom( "super-cool-gang" );
    
  } );
}
```

## Broadcasting to rooms

The main purpose of rooms is that you can broadcast to them. You can do this at both the namespace level, and also the socket level (broadcast to everyone in the room except the socket client). When passing rooms to the broadcast and emit methods, you either pass a single string room name, or an array of room names:

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){

    socket.joinRoom( "super-cool-gang" );

    // broadcast to everyone in the room(s), including the socket client
    ns.emit( event="coolGangJoiner", args="Someone joined...", rooms="super-cool-gang" );

    // broadcast to everyone in the room(s), excluding the socket client
    socket.broadcast( "coolGangJoiner", args="Someone joined super-cool-gang..", rooms=[ "super-cool-gang", "sysadmins" ] );    
  } );
}
```

**Challenge:** write your own front-end listeners for the events above.


## Leaving rooms

You can leave rooms with `socket.leaveRoom( roomName )` and `socket.leaveAllRooms()`:

```cfc
private void function setupListeners() {
  var io = application.io;
  var ns = io.of( "/admin" );

  ns.on( "connect", function( socket ){

    socket.joinRoom( "super-cool-gang" );

    socket.on( "customLeaveRoomEvent", function( roomName ){
      socket.leaveRoom( arguments.roomName );
    } );

    socket.on( "customLeaveEvent", function(){
      socket.leaveAllRooms();
    });
    
  } );
}
```

**Challenge:** write your own front-end listeners for the events above. Hint: you may want to add some UI to your page to trigger events.


**Next:** [7. Chat application](7-chatapp.html)