#!/bin/bash
set -e  # 遇到错误时自动退出脚本

show_help() {
    echo "用法: $0 [架构]"
    echo "可用架构:"
    echo "  x64    - 64位Intel/AMD架构 (默认)"
    echo "  arm32  - 32位ARM架构"
    echo "  arm64  - 64位ARM架构"
    exit 1
}

# 默认架构为x64
ARCH="x64"

# 处理参数
if [ $# -gt 1 ]; then
    show_help
elif [ $# -eq 1 ]; then
    case "$1" in
        x64|amd64|x86_64)
            ARCH="x64"
            ;;
        arm32|arm|armv7)
            ARCH="arm32"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "错误: 不支持的架构 '$1'"
            show_help
            ;;
    esac
fi

# 架构到RID的映射
declare -A RID_MAP=(
    [x64]="linux-x64"
    [arm32]="linux-arm"
    [arm64]="linux-arm64"
)

RID=${RID_MAP[$ARCH]}

echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
echo "█ 正在构建目标架构: $ARCH (RID: $RID)"
echo "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"

# 步骤1: 编译mylib.cj
echo "➤ 编译mylib.cj (输出为.so)"
cjc mylib.cj --output-type=dylib || {
    echo "✖ mylib.cj编译失败!"
    exit 2
}

# 步骤2: 发布C#项目
echo "➤ 编译C#库 (架构: $ARCH)"
dotnet publish ./CSLibrary/CSLibrary.csproj -c Release -r $RID -o . || {
    echo "✖ C#库编译失败!"
    exit 3
}

# 步骤3: 编译主程序
echo "➤ 编译主程序 (链接CSLibrary)"
cjc -L . -l CSLibrary ./main.cj || {
    echo "✖ 主程序编译失败!"
    exit 5
}

echo "✔ 构建成功!"
echo "输出文件: $(pwd)/main"