var io = require('socket.io-client');
var socket = io( 'http://127.0.0.1:3000/' );

socket.on( "connect", function() {
    console.log( "connect success" );
    process.exit(0);
} );

socket.connect();

setTimeout(function () {
    console.log( "connect timeout" );
    process.exit(1);
}, 2000);
