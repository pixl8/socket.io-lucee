var io = require('socket.io-client');
var socket = io('http://127.0.0.1:3000');

socket.on('foo', function (bar, callback) {
    if (bar === 'bar') {
    	callback( 'baz' );
    	setTimeout(function () {
            process.exit(0);
        }, 1000);
    }
});

setTimeout(function () {
    process.exit(1);
}, 3000);