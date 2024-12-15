#!/bin/bash

MODULE_NAME=example
if [ ! -e ./go.mod ];then
    go mod init
fi

go mod tidy

go build -o output/bin/$MODULE_NAME
cp -r configs output/