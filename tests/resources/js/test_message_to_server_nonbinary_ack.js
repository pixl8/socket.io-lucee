var io = require('socket.io-client');

var socket = io('http://127.0.0.1:3000/');

var ackReceived = false;

socket.on('connect', function () {
    socket.emit('foo', 1, 'bar', function(baz) {
        // Ack received
        if (baz === 'baz') {
        	ackReceived = true;
        }
    });
});

var pollInterval = setInterval(function () {
    if (ackReceived) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    console.log( "Timed out waiting for ack" );
    process.exit(1);
}, 10000);