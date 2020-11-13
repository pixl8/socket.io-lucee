#!/bin/sh

if [ ! -d ./testbox ] ; then
	echo "Installing testbox (this should happen only once)"
	box install
fi

exitcode=0

box stop name="luceesocketio-tests"
box start directory="./" serverConfigFile="./server-tests.json"
box testbox run verbose=true || exitcode=1
box stop name="workflowtests"

exit $exitcode

