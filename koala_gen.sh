#!/bin/bash

# 初始化变量
module_name=""
idl_filename=""
default_module_name="internal_default_go_module_name"
need_help=false
# 定义帮助信息输出函数
print_help() {
    echo "使用说明:"
    echo "  $0 [-m|--module <模块名>] [-i|--idl <IDL 文件名>] [-h|--help]"
    echo "选项:"
    echo "  -m, --module <模块名>    指定模块名"
    echo "  -i, --idl <IDL 文件名>   指定 IDL 文件名，此选项为必需选项"
    echo "  -h, --help               显示此帮助信息"
}
# 使用 getopt 解析选项
ARGS=$(getopt -o m:i:h --long module:,idl:,help -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    echo "选项解析失败" >&2
    exit 1
fi
#echo $ARGS
#result=$(eval set -- "$ARGS")
#echo "aftert eval $ARGS"

while true; do
    case "$1" in
        -m|--module)
            echo "选项 -m/--module 被指定，参数值为: $2"
            module_name="$2"
            shift 2
            ;;
        -i|--idl)
            echo "选项 -i/--idl 被指定，参数值为: $2"
            idl_filename="$2"
            shift 2
            ;;
        -h|--help)
            need_help=true
            shift
            break  # 当遇到 --help 时，跳出循环，不再继续处理其他选项
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            #echo "未知选项: $1" >&2
            #exit 1
            ;;
    esac
done
# 先检查是否需要显示帮助信息
if $need_help; then
    print_help
    exit 0
fi
# 检查必需选项是否提供
if [ -z "$idl_filename" ]; then
    echo "[error] Required option '-i' is missing" >&2
    print_help
    exit 1
fi
echo "module_name: $module_name"
echo "idl_filename: $idl_filename"

openapi-generator generate --template-dir ./  -g go-server  -i "$idl_filename" -o "$module_name"

rm -rf $module_name/go/*_service.go
cp -r configs $module_name/

cp -r script/Makefile $module_name/
mkdir -p $module_name/script
cp script/start.sh $module_name/script/
cp -r script/build.sh $module_name/script/

sed -i '' "s#github.com/GIT_USER_ID/GIT_REPO_ID#$module_name#g" "./$module_name/main.go"
sed -i '' "s#$default_module_name#$module_name#g" "./$module_name/go.mod"

for file in ./$module_name/script/*.sh; do
    if [ -f "$file" ]; then
        sed -i '' "s#$default_module_name#$module_name#g" "$file"
        chmod +x "$file"
    fi
done
cp $module_name/script/build.sh $module_name/
chmod +x $module_name/build.sh


