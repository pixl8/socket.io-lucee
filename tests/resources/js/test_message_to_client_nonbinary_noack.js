var io = require('socket.io-client');
var socket = io('http://127.0.0.1:3000/');

socket.on('foo', function (bar) {
    if (bar === 'bar') {
    	console.log( 'message received' );
        process.exit(0);
    }
});

setTimeout(function () {
	console.log( 'timed out waiting for message' );
    process.exit(1);
}, 2000);