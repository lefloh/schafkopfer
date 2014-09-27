#!/bin/sh

# expecting following env-variable:
# WEB_HOST=user@host

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$SCRIPT_DIR/.."

DEPLOYMENT_ROOT=/var/dart/schafkopfer_server
APP=schafkopfer_server.tar.gz

DEPLOY="function deploy {
    sudo rm -rf $DEPLOYMENT_ROOT/*
    cd $DEPLOYMENT_ROOT
    sudo tar -xzf ~/$APP
    sudo chown -R dart:dart *
    sudo service schafkopfer_server restart
    rm ~/$APP
}"

rm -rf $BASE_DIR/build/*

dart --snapshot=$BASE_DIR/build/schafkopfer_server.snapshot $BASE_DIR/bin/schafkopfer_server_main.dart

tar -czf $APP -C $BASE_DIR build configs
scp $APP $WEB_HOST:~
ssh -t $WEB_HOST "$DEPLOY; deploy "
rm $APP