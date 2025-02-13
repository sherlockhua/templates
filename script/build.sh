#!/bin/bash

MODULE_NAME=internal_default_go_module_name
if [ ! -e ./go.mod ];then
    go mod init
fi

go mod tidy

go build -o output/bin/$MODULE_NAME
cp -r configs output/
cp ./script/start.sh ./output/
chmod +x ./output/start.sh