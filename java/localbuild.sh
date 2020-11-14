#!/bin/bash

rm -rf artifacts/*
mvn package
cd artifacts
unzip cfsocket-1.0.0.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Lucee WebsSocket Wrapper
Bundle-SymbolicName: com.pixl8.cfsocket
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm cfsocket-1.0.0.jar
zip -rq cfsocket-1.0.0.jar *

cp cfsocket-1.0.0.jar ../../lib/
