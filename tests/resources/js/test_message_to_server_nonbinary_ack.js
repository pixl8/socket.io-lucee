var io = require('socket.io-client');

var socket = io('http://127.0.0.1:3000/');

socket.on('connect', function () {
    socket.emit('foo', 1, 'bar', function(baz) {
        // Ack received
        if (baz === 'baz') {
            process.exit(0);
        }
    });
});

setTimeout(function () {
    process.exit(1);
}, 2000);