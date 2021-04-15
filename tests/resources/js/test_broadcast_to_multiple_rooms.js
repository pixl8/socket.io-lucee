var io = require('socket.io-client');

var fooReceived = [0, 0, 0];
var successCheck = function(){
    if ( fooReceived[0] == 1 && fooReceived[1] == 1 && fooReceived[2] == 1 ) {
        console.log( "success" );
        process.exit(0);
    }
}

var socket1 = io( 'http://127.0.0.1:3000/' );
var socket2 = io( 'http://127.0.0.1:3000/' );
var socket3 = io( 'http://127.0.0.1:3000/' );

socket1.on('connect', function() {
    socket1.emit('join_foo');
    socket1.emit('join_bar');
});
socket1.on('foo', function () {
    fooReceived[0]++;
    successCheck();
});

socket2.on('connect', function() {
    socket2.emit('join_foo');
});
socket2.on('foo', function () {
    fooReceived[1]++;
    successCheck();
});

socket3.on('connect', function() {
    socket3.emit('join_bar');
});
socket3.on('foo', function () {
    fooReceived[2]++;
    successCheck();
});

setTimeout(function () {
    successCheck();
    console.log( "failure" );
    process.exit(1);
}, 2000);