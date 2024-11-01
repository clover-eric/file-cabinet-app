#!/bin/bash

# 输出颜色配置
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}开始创建网络文件柜程序...${NC}"

# 创建项目文件夹
echo "创建项目目录..."
mkdir cm-box

# 复制安装和启动脚本
cp setup.sh cm-box/
cp start.sh cm-box/

# 设置权限
chmod +x cm-box/setup.sh
chmod +x cm-box/start.sh

echo -e "${GREEN}项目创建完成！${NC}"
echo "请执行以下命令开始安装："
echo "cd cm-box"
echo "./setup.sh" 