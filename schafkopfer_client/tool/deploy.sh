#!/bin/sh

# expecting following env-variables:
# BASE_DOCUMENT_ROOT=/var/www/yoursite/html
# WEB_HOST=user@host

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$SCRIPT_DIR/.."

DEPLOYMENT_ROOT=BASE_DOCUMENT_ROOT/schafkopfer
APP=schafkopfer_client.tar.gz

DEPLOY="function deploy {
    sudo rm -rf $DEPLOYMENT_ROOT/*
    cd $DEPLOYMENT_ROOT
    sudo tar -xzf ~/$APP
    sudo chown -R www-data:www-data *
    rm ~/$APP
}"

cd $BASE_DIR

pub build

cd $BASE_DIR/build/web

tar -czf $APP *
scp $APP $WEB_HOST:~
ssh -t $WEB_HOST "$DEPLOY; deploy "
rm $APP