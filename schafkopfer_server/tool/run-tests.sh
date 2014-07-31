#!/bin/sh

export SCHAFKOPFER_ENV=test

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_DIR="$SCRIPT_DIR/../test/"

if pgrep mongod >/dev/null 2>&1; then
  MONGO_RUNNING="TRUE"
else
  mongod --config $MONGO_DATA/mongod.conf &
fi

dart $SCRIPT_DIR/../bin/schafkopfer_server_main.dart &
DART_PID=$!

cd $TEST_DIR

for test in *_test.dart
do
  echo "\n### running $test\n"
  dart $test
done

if [ "x$MONGO_RUNNING" != "xTRUE" ]; then
  killall mongod
fi

kill -9 $DART_PID

exit 0