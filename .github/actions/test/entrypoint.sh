#!/bin/sh

BOXJSON_DIR=${INPUT_BOXJSON_DIR:-""}
TEST_DIR=${INPUT_TEST_DIR:-"/tests"}
TEST_SERVER_JSON=${INPUT_TEST_SERVER_JSON:-"$TEST_DIR/server.json"}
OUTPUT_FILE=${INPUT_OUTPUT_FILE:-""}
VERBOSE=${INPUT_VERBOSE:-"false"}
FULL_DIR="${GITHUB_WORKSPACE}${BOXJSON_DIR}"
BOX_JSON_FILE="${FULL_DIR}/box.json"

if [[ ! -d "${GITHUB_WORKSPACE}${TEST_DIR}" ]] ; then
	echo "Test directory not found. Cannot run tests."
	exit 1
fi

if [[ ! -f "${GITHUB_WORKSPACE}${TEST_SERVER_JSON}" ]] ; then
	echo "$TEST_SERVER_JSON file not found. Cannot run tests."
	exit 1
fi

if [[ ! -f $BOX_JSON_FILE ]] ; then
	echo "No box.json file found at: $BOX_JSON_FILE. Cannot run tests."
	exit 1
fi

echo "Starting test server..."
box start directory="${GITHUB_WORKSPACE}${TEST_DIR}" serverConfigFile="${GITHUB_WORKSPACE}${TEST_SERVER_JSON}" || exit 1

echo "Running tests"
cd $FULL_DIR
exitcode=0
box testbox run verbose=$VERBOSE > ${GITHUB_WORKSPACE}${OUTPUT_FILE} || exitcode=1
cat ${GITHUB_WORKSPACE}${OUTPUT_FILE}

exit $exitcode