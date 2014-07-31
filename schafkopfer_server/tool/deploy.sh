#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$SCRIPT_DIR/.."

DEPLOYMENT_ROOT=/var/dart/schafkopfer_server
APP=schafkopfer_server.tar.gz

DEPLOY="function deploy {
    sudo rm -rf $DEPLOYMENT_ROOT/*
    cd $DEPLOYMENT_ROOT
    sudo tar -xzf ~/$APP
    sudo chown -R dart:dart *
    sudo service schafkopfer_server restart 2>&1 &
    sleep 1
    rm ~/$APP
}"

rm $BASE_DIR/build/*

dart --snapshot=$BASE_DIR/build/schafkopfer_server.snapshot $BASE_DIR/bin/schafkopfer_server_main.dart

tar -czf $APP -C $BASE_DIR build resources
scp $APP floh@morten:~
ssh -t floh@morten "$DEPLOY; deploy "
rm $APP