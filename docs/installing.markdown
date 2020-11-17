---
layout: page
title: Installation
permalink: /installing/
nav_order: 3
---

# How to install this project

*Note: the instructions here will only be valid after we have made our first release.*

## Direct from Github

Packaged releases are available straight from the Github project. Head to the releases page to download a zip file of a particular version:

[https://github.com/pixl8/socket.io-lucee/releases](https://github.com/pixl8/socket.io-lucee/releases)

Unzip the package somewhere to your project and make a mapping to the root directory named whatever you like, for example: `/luceesocketio`. You can then get started with:

```cfc
io = new luceesocketio.models.SocketIoServer();
```

## Using Commandbox

We publish releases to [Forgebox](https://forgebox.io) and you can install them using CommandBox with:

```
box install socket-io-lucee
```

This will create a `socket.io-lucee` directory at the root of the install. If you wish to install it somewhere else you can specify the installation directory with the `box install` command (see [CommandBox documentation](https://commandbox.ortusbooks.com/package-management/installing-packages) for details).

### For Coldbox

*TODO: Create a package in Forgebox specifically to install as a ColdBox.*module.