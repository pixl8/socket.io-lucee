<!DOCTYPE html>
<html>
<head>
	<title>Socket.io-Lucee: Tutorial</title>
	<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
	<script>
		// making a connection to our Socket.io-Lucee server
		var socket = io( "127.0.0.1:3000" );

		socket.on('message', function(data){document.write(data)});
	</script>
</head>
<body>
</body>
