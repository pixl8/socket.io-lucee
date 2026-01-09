var io = require('socket.io-client');
var socket = io( 'http://127.0.0.1:3000/' );

var connected = false;

socket.on( "connect", function() {
    connected = true;
} );

socket.connect();

var pollInterval = setInterval(function () {
    if (connected) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        console.log( "connect success" );
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    console.log( "connect timeout" );
    process.exit(1);
}, 10000);
