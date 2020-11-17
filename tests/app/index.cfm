<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
  <script>
    var socket = io( "127.0.0.1:3000" );

    socket.on( 'message', function( msg ) {
      document.body.innerHTML = '';
      document.write( msg );
    });
    socket.on( 'clientAlert', function( data ) {
      document.body.innerHTML = '';
      document.write( data.description );
    });

  </script>
</head>
<body>
</body>
</html>