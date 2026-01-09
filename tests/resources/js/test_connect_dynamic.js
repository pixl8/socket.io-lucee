var io = require('socket.io-client');
var port = process.env.PORT || 3000;

var fooConnections = {
    0: false,
    'a': false,
    1: false
};
var barConnection = false;

var socket1 = io('http://127.0.0.1:' + port + '/foo0', {
    autoConnect: false,
    transports: ['websocket']
});
socket1.on('connect', function () {
    fooConnections[0] = true;
});
socket1.connect();

var socket2 = io('http://127.0.0.1:' + port + '/fooa', {
    autoConnect: false,
    transports: ['websocket']
});
socket2.on('connect', function () {
    fooConnections['a'] = true;
});
socket2.connect();

var socket3 = io('http://127.0.0.1:' + port + '/foo1', {
    autoConnect: false,
    transports: ['websocket']
});
socket3.on('connect', function () {
    fooConnections[1] = true;
});
socket3.connect();

var socket4 = io('http://127.0.0.1:' + port + '/bar', {
    autoConnect: false,
    transports: ['websocket']
});
socket4.on('connect', function () {
    barConnection = true;
});
socket4.connect();

var pollInterval = setInterval(function () {
    if (fooConnections[0] && fooConnections[1] && !fooConnections['a'] && !barConnection) {
        clearInterval(pollInterval);
        clearTimeout(timeout);
        process.exit(0);
    }
}, 50);

var timeout = setTimeout(function () {
    clearInterval(pollInterval);
    process.exit(1);
}, 10000);
