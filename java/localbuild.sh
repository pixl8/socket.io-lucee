#!/bin/bash

rm -rf artifacts/*
mvn package
cd artifacts
unzip socketio-lucee-1.0.0.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: SocketIO-Java Server Implementation with Lucee bindings
Bundle-SymbolicName: com.pixl8.socketio-lucee
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm socketio-lucee-1.0.0.jar
zip -rq socketio-lucee-1.0.0.jar *

cp socketio-lucee-1.0.0.jar ../../lib/
