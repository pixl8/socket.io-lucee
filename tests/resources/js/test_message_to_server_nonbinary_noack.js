var io = require('socket.io-client');
var socket = io( 'http://127.0.0.1:3000/' );

socket.on('connect', function () {
    socket.emit('foo', 1, 'bar');

    setTimeout(function () {
        process.exit(0);
    }, 100);
});

setTimeout(function () {
    process.exit(1);
}, 2000);