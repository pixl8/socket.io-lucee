---
layout: page
title: Build from source
permalink: /building/
nav_order: 6
---

# Building from source

This project contains it's own Java sub-project for building the Jetty servlet container that handles the Socket.IO http and websocket connections aswell as managing socket namespace and room associations. If you checkout the source code of this project, you will need to build this project from source to generate the `.jar` library file that the Lucee code relies on.

## Dependencies

You will need to have [Maven](https://maven.apache.org/) installed and have a working bash terminal to run the build script.

## Run the build

From the terminal:

```bash
cd java/
./localbuild.sh
```

## Windows users

There is no local batch script available at this point. At the very least, you can download the latest built version of the software and locate the `.jar` file from the `/lib` directory. If you need/want to work on the java source code, you'll need to figure a way to emulate our bash script that currently does some horrible hack to make a OSGi bundle out of our jar file after building with `mvn package`.