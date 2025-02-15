#!/bin/bash

MODULE_NAME=internal_default_go_module_name
SOURCE_DIR=internal_default_go_src_dir
if [ ! -e ./go.mod ];then
    go mod init
fi

go mod tidy

go build -o output/bin/$MODULE_NAME $SOURCE_DIR
cp -r configs output/
cp ./script/start.sh ./output/
chmod +x ./output/start.sh