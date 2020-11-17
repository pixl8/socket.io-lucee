---
layout: page
title: Hosting guide
permalink: /hosting/
nav_order: 5
---

# Hosting configuration for your socket.io server

## Summary

When you start up Socket.io-lucee server you create an embedded java servlet container running on its own port, by default `3000`:

```cfc
// create a new server with default configuration and automatically start it
io = new luceesocketio.models.SocketIoServer();

// or, use your own settings and manually start yourself
io = new luceesocketio.models.SocketIoServer( start=false, port=8888, host=mysitehostname );
...
io.start();
```

At this point, you have two servlet containers running:

1. The servlet container running Lucee (e.g. Tomcat, Commandbox/Undertow, etc.)
2. The Socket.io servlet container embeeded in your Lucee application, running on Jetty

You can now use the system by setting your clients to access the embedded server port directly. i.e., in javascript:

```html
<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
<script>
	var socket = io( "mysite.com:3000/" );
	// ...
</script>
```

This is most likely undesirable for multiple reasons:

1. no SSL
2. requires making an additional, non-default port open on your server

## Proxying with your webserver

One of the advantages to websockets is that they can share the same port as your regular HTTP traffic by using HTTP/1.1 upgrades. This means that you can configure your web server to upgrade your websocket traffic and continue to use your SSL certificate on your webserver. In this scenario, your clientside connection would look like this:

```html
<script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
<script>
	var socket = io(); // defaults to the same domain, port and protocol as the current page
	// ...
</script>
```

It is worth noting that Socket.io sends all traffic through a `/socket.io/` path, which makes it trivial to filter traffic that will be proxied to our Socket.io-Lucee servlet container.

### Using NGINX

Use the `location` block below to proxy all **socket.io** traffic to our Socket.io-lucee servlet:

```nginx
location /socket.io/ {
	proxy_http_version 1.1;
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection $connection_upgrade;

	# Proxy to the Socket.io-lucee servlet
	proxy_pass http://localhost:3000;
}
```

### Using Apache

TODO: Get and document a working solution in IIS.

### Using IIS

TODO: Get and document a working solution in IIS.

