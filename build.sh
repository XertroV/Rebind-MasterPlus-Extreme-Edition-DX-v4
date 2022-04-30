#!/usr/bin/env bash

PLUGIN_NAME=plugin-test
BUILD_NAME=$PLUGIN_NAME-$(date +%s).zip
RELEASE_NAME=$PLUGIN_NAME-latest.op
PLUGIN_DIR=$HOME/win/OpenplanetNext/Plugins/

7z a ./$BUILD_NAME ./src/*

cp -v $BUILD_NAME $RELEASE_NAME

cp -v $RELEASE_NAME $PLUGIN_DIR

echo "Built plugin as ${BUILD_NAME} and copied to ./${RELEASE_NAME} and ${PLUGIN_DIR}."
