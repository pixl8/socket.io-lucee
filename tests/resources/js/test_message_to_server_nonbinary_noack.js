var io = require('socket.io-client');
var socket = io( 'http://127.0.0.1:3000/' );

var messageSent = false;

socket.on('connect', function () {
    socket.emit('foo', 1, 'bar');

    setTimeout(function () {
        messageSent = true;
    }, 500);
});

var pollInterval = setInterval(function () {
    if (messageSent) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    process.exit(1);
}, 10000);