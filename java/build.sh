#!/bin/bash

cd lucee-javax
rm -rf artifacts
mkdir -p artifacts
mvn package
cp target/socketio-lucee-1.0.0-jar-with-dependencies.jar artifacts/socketio-lucee-javax.jar
cd artifacts
unzip -q socketio-lucee-javax.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: SocketIO-Java Server Implementation with Lucee bindings
Bundle-SymbolicName: com.pixl8.socketio-lucee
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm socketio-lucee-javax.jar
zip -rq socketio-lucee-javax.jar *

cp socketio-lucee-javax.jar ../../../lib/

cd ../../lucee-jakarta
rm -rf artifacts
mkdir -p artifacts
mvn package
cp target/socketio-lucee-jakarta-1.0.0-jar-with-dependencies.jar artifacts/socketio-lucee-jakarta.jar
cd artifacts
unzip -q socketio-lucee-jakarta.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: SocketIO-Java Server Implementation with Lucee bindings
Bundle-SymbolicName: com.pixl8.socketio-lucee
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm socketio-lucee-jakarta.jar
zip -rq socketio-lucee-jakarta.jar *

cp socketio-lucee-jakarta.jar ../../../lib/

cd ../../