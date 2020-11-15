#!/bin/bash

rm -rf artifacts/*
mvn package
cd artifacts
unzip luceesocketio-1.0.0.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Lucee SocketIO Wrapper
Bundle-SymbolicName: com.pixl8.luceesocketio
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm luceesocketio-1.0.0.jar
zip -rq luceesocketio-1.0.0.jar *

cp luceesocketio-1.0.0.jar ../../lib/
