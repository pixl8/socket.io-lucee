var io = require('socket.io-client');

var fooReceived = [false, false];
function testReceived() {
    if (fooReceived[0] && fooReceived[1]) {
        console.log( "messages received" );
        process.exit(0);
    }
}

var socket1 = io( 'http://127.0.0.1:3000' );
socket1.on('foo', function () {
    fooReceived[0] = true;
    testReceived();
});

var socket2 = io( 'http://127.0.0.1:3000' );
socket2.on('foo', function () {
    fooReceived[1] = true;
    testReceived();
});

setTimeout(function () {
    console.log( "Timed out waiting / did not receive." );
    process.exit(1);
}, 2000);