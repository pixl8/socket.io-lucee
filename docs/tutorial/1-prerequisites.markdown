---
layout: page
title: 1. Prerequisites
nav_order: 1
parent: Tutorial
---

# 1. Prerequisites

We will be using CommandBox to spin up a server and install the Socket.io-lucee library. If you haven't already, head over to the [CommandBox installation guide](https://commandbox.ortusbooks.com/setup/installation) and get it installed. 

> _Note: it is possible to complete this tutorial with any other method of installing the library and starting a Lucee server - we just find this way to be the most convenient._

Once you have CommandBox installed and working, create an empty directory for this tutorial, and install this library:

```bash
mkdir -p ~/lucee-socket-io-tutorial
cd ~/lucee-socket-io-tutorial
box install socket-io-lucee
```

Next, add the two files below to the root of the directory:

**Application.cfc**

```cfc
component {

  this.name = "socket.io-lucee tutorial";

  processingdirective preserveCase="true";

  public void function onRequest( required string requestedTemplate ) output=true {
    include template=arguments.requestedTemplate;
  }

}
```

**index.cfm**

```html
<!DOCTYPE html>
<html>
<head>
  <title>Socket.io-Lucee: Tutorial</title>
  <script src="https://cdn.socket.io/socket.io-2.3.1.js"></script>
</head>
<body>
</body>
</html>
```

Finally, startup your Lucee application using the `box start` command in your terminal. 

> _Note: We're adding `--console` to the command so that we can easily trace background messages to demonstrate activity._

```bash
cd ~/lucee-socket-io-tutorial
box start --console
```

This should start the server and open up a browser window loading our `index.cfm` file (an empty HTML page). We're all set!

**Next:** [2. Making a connection](2-connection.html)