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

setTimeout(function () {
    if (barReceived[0] !== barReceived[1]) {
        console.log( "success" );
        process.exit(0);
    } else {
        console.log( "failure" );
        process.exit(1);
    }
}, 2000);