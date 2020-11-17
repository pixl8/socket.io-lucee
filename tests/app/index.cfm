<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000/admin" ); // var socket = io( "/admin" ); <-- if using default host and port

    socket.on( 'message', function( msg ) {
      document.body.innerHTML = '';
      document.write( msg );
    });
  </script>
</head>
<body>
</body>
</html>