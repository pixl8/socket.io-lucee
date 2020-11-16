<!DOCTYPE html>
<html>
<head>
	<title>Socket.io-Lucee: Test harness</title>
</head>
<body>
	<script src="http://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
	<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
	<script>
		var socket = io( "127.0.0.1:3000/admin" );

		socket.on( 'connect', function(){
			setTimeout(function(){
				socket.emit('clientEvent', { "test":"object messaging..." } );
			 }, 5000);
			$( "#output" ).append( $( "<p>Connected!</p>" ) );

			socket.on('disconnect', function(){
				$( "#output" ).append( $( "<p>Disconnected!</p>" ) );
			}).on( 'welcome', function( msg ) {
				$( "#output" ).append( $( "<p><strong>" + msg + "</strong></p>" ) );
			}).on( 'newmember', function( msg ) {
				$( "#output" ).append( $( "<p><strong>" + msg + "</strong></p>" ) );
			});
		});

	</script>

	<div id="output"></div>
</body>
</html>