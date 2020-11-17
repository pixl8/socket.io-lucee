<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    // socket.on('testEvent', function(data){document.write(data)});
    socket.emit('clientEvent', 'Sent an event from the client!');
  </script>
</head>
<body>
</body>