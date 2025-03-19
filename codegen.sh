#!/bin/bash

# 初始化变量
module_name=""
idl_filename=""
relative_path=""
output_dir=""
source_dir=""
default_module_name="internal_default_go_module_name"
default_source_dir="internal_default_go_src_dir"
need_help=false
# 定义帮助信息输出函数
print_help() {
    echo "使用说明:"
    echo "  $0 [-m|--module <模块名>] [-i|--idl <IDL 文件名>] [-r|--relative <生成代码的相对位置>]  [-h|--help]"
    echo "选项:"
    echo "  -m, --module <模块名>    指定模块名"
    echo "  -i, --idl <IDL 文件名>   指定 IDL 文件名，此选项为必需选项"
    echo "  -r, --relative <生成代码的相对位置>   指定生成代码的相对路径，默认当前位置，比如指定 server/http_server, 生成代码的位置是./server/http_server/"
    echo "  -h, --help               显示此帮助信息"
}
# 使用 getopt 解析选项
ARGS=$(getopt -o m:i:o:h --long module:,idl:,output:,help -n "$0" -- "$@")
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
        -r|--relative)
            echo "选项 -r/--relative 被指定，参数值为: $2"
            relative_path="$2"
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

output_dir="$module_name"
module_path=$module_name

if [ ! -z "$relative_path" ]; then
    output_dir="$module_name/$relative_path"
    module_path=$output_dir
    source_dir="$module_path"
fi

echo "module_name: $module_name"
echo "idl_filename: $idl_filename"
echo "output_dir: $output_dir"

#backup impl.go
if [ -f "$output_dir/go/impl.go" ]; then
   mv "$output_dir/go/impl.go" "$output_dir/go/impl.go.bak"
fi

openapi-generator generate --template-dir ./  -g go-server  -i "$idl_filename" -o "$output_dir"

if [ -f "$output_dir/go/impl.go.bak" ]; then
   mv "$output_dir/go/impl.go.bak" "$output_dir/go/impl.go"
fi

rm -rf $output_dir/go/*_service.go
cp -r configs $module_name/

cp -r script/Makefile $module_name/
mkdir -p $module_name/script
cp script/start.sh $module_name/script/
cp -r script/build.sh $module_name/script/

if [ "$output_dir" != "$module_name" ]; then
    mv "./$output_dir/go.mod" "./$module_name/"
fi


sed -i '' "s#github.com/GIT_USER_ID/GIT_REPO_ID#$module_path#g" "./$output_dir/main.go"
sed -i '' "s#$default_module_name#$module_name#g" "./$module_name/go.mod"

for file in ./$module_name/script/*.sh; do
    if [ -f "$file" ]; then
        sed -i '' "s#$default_module_name#$module_name#g" "$file"
        sed -i '' "s#$default_source_dir#$source_dir#g" "$file"
        chmod +x "$file"
    fi
done
cp $module_name/script/build.sh $module_name/
chmod +x $module_name/build.sh

# create directory for generated code
mkdir -p $module_name/internal/domain
mkdir -p $module_name/internal/infra/repository
mkdir -p $module_name/internal/application


