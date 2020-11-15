<!DOCTYPE html>
<html>
<head>
	<title>Socket.io-Lucee: Test harness</title>
</head>
<body>
	<script src="http://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
	<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
	<script>
    	var ns = io( "127.0.0.1:3000/admin" );

        ns.on( 'connect', function(){
            $( "#output" ).append( $( "<p>Connected!</p>" ) );
            ns.emit('clientEvent', 'Sent an event from the client!');
        })
        ns.on('disconnect', function(){
            $( "#output" ).append( $( "<p>Disconnected!</p>" ) );
        });
    </script>

    <div id="output"></div>
</body>
</html>