var io = require('socket.io-client');

var socket = io('http://127.0.0.1:3000/');

socket.on('connect', function () {
    socket.emit('foo', 1, 'bar', function(baz) {
        // Ack received
        if (baz === 'baz') {
        	console.log( baz );
            process.exit(0);
        }
    });
});

setTimeout(function () {
    console.log( "Timed out waiting for ack" );
    process.exit(1);
}, 2000);