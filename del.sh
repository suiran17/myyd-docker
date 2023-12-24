#!/bin/bash

# 替换 'path/to/A' 为你的目录 A 的实际路径
root_dir="./"

for dir in "$root_dir"/*/; do
    git_dir="$dir.git"
    if [ -d "$git_dir" ]; then
        echo "Deleting $git_dir"
        rm -rf "$git_dir"
    fi
done

