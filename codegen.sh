#!/bin/bash

project=example
current_dir=`pwd`
echo $current_dir
last_part=`basename $current_dir`
echo $last_part

openapi-generator generate --template-dir ./  -g go-server  -i ./pet.yaml -o $project

rm -rf $project/go/*_service.go
rm -rf $project/go.mod
cp -r configs $project/

cp script/* $project/
sed -i '' 's#github.com/GIT_USER_ID/GIT_REPO_ID/go#$last_part#g' ./$project/main.go
