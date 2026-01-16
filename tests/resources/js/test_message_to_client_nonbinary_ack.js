var io = require('socket.io-client');
var socket = io('http://127.0.0.1:3000');

var ackSent = false;

socket.on('foo', function (bar, callback) {
    if (bar === 'bar') {
    	callback( 'baz' );
    	ackSent = true;
    }
});

var pollInterval = setInterval(function () {
    if (ackSent) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    process.exit(1);
}, 10000);