var io = require('socket.io-client');
var barReceived = [false, false];

var socket1 = io( 'http://127.0.0.1:3000/' );
var socket2 = io( 'http://127.0.0.1:3000/' );

socket1.on('connect', function () {
    socket1.emit('foo');
});
socket1.on('bar', function () {
    barReceived[0] = true;
});

socket2.on('connect', function () {
    socket2.emit('foo');
});
socket2.on('bar', function () {
    barReceived[1] = true;
});

var pollInterval = setInterval(function () {
    if (barReceived[0] !== barReceived[1]) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        console.log( "success" );
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    console.log( "failure" );
    process.exit(1);
}, 10000);