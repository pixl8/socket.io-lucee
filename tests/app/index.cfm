<!DOCTYPE html>
<html>
   <head>
     <title>Socket.io-Lucee: Tutorial (Chat demo)</title>
     <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
     <script>
      var socket = io( "127.0.0.1:3000" );
      function setUsername() {
       socket.emit('setUsername', document.getElementById('name').value);
      };
      var user;
      socket.on('userExists', function(data) {
       document.getElementById('error-container').innerHTML = data;
      });
      socket.on('userSet', function(username) {
       user = username;
       document.body.innerHTML = '<input type = "text" id = "message">\
       <button type = "button" name = "button" onclick = "sendMessage()">Send</button>\
       <div id = "message-container"></div>';
      });
      function sendMessage() {
       var msg = document.getElementById('message').value;
       if(msg) {
        socket.emit('msg', {message: msg, user: user});
       }
      }
      socket.on('newmsg', function(data) {
       if(user) {
        document.getElementById('message-container').innerHTML += '<div><b>' +
           data.user + '</b>: ' + data.message + '</div>'
       }
      })
      socket.on( "test", function( blah, callback ) {
        console.log( blah );
        callback( "hello back!" );
      } );
     </script>
   </head>


   <body>
    <div id = "error-container"></div>
    <input id = "name" type = "text" name = "name" value = ""
     placeholder = "Enter your name!">
    <button type = "button" name = "button" onclick = "setUsername()">
     Let me chat!
    </button>
   </body>
</html>