var io = require('socket.io-client');
var fooReceived = [false, false, false];

var socket1 = io( "http://127.0.0.1:3000/" );
socket1.on('connect', function() {
    socket1.emit('join');
});
socket1.on('foo', function () {
    fooReceived[0] = true;
});

var socket2 = io( "http://127.0.0.1:3000/" );
socket2.on('connect', function() {
    socket2.emit('join');
});
socket2.on('foo', function () {
    fooReceived[1] = true;
});

var socket3 = io( "http://127.0.0.1:3000/" );
socket3.on('foo', function () {
    fooReceived[2] = true;
});

setTimeout(function () {
    if (fooReceived[0] && fooReceived[1] && !fooReceived[2]) {
        console.log( "success" );
        process.exit(0);
    } else {
        console.log( "failure" );
        process.exit(1);
    }
}, 2000);