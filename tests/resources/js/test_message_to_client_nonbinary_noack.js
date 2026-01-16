var io = require('socket.io-client');
var socket = io('http://127.0.0.1:3000/');

var messageReceived = false;

socket.on('foo', function (bar) {
    if (bar === 'bar') {
    	messageReceived = true;
    }
});

var pollInterval = setInterval(function () {
    if (messageReceived) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        console.log( 'message received' );
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
	console.log( 'timed out waiting for message' );
    process.exit(1);
}, 10000);