#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号和仓库地址
VERSION="1.0.0"
REPO_URL="https://raw.githubusercontent.com/clover-eric/file-cabinet-app/main"

echo -e "${GREEN}开始部署网络文件柜 v${VERSION}...${NC}"

# 检查必要的命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}错误: $1 未安装${NC}"
        echo "请先安装 $1: $2"
        exit 1
    fi
}

check_command "docker" "https://docs.docker.com/get-docker/"
check_command "docker-compose" "https://docs.docker.com/compose/install/"
check_command "curl" "使用系统包管理器安装"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载文件函数
download_file() {
    local file=$1
    local url="${REPO_URL}/${file}"
    local dir=$(dirname "$file")
    
    mkdir -p "$dir"
    if ! curl -sSL "$url" -o "$file"; then
        echo -e "${RED}下载 $file 失败${NC}"
        return 1
    fi
}

# 下载必要的文件
echo -e "${BLUE}下载源代码文件...${NC}"
files=(
    "docker-compose.yml"
    "Dockerfile"
    "package.json"
    "webpack.config.js"
    "server.js"
    ".babelrc"
    "src/index.js"
    "src/App.js"
    "src/index.css"
    "src/api/api.js"
    "src/context/AuthContext.js"
    "public/index.html"
)

for file in "${files[@]}"; do
    download_file "$file" || exit 1
done

# 创建 .env 文件
cat > .env << EOL
REACT_APP_API_URL=http://localhost:3001
REACT_APP_STORAGE_PATH=./storage
EOL

# 清理旧的部署
echo -e "${BLUE}清理旧的部署...${NC}"
docker-compose down -v 2>/dev/null
docker rmi cm-box:latest 2>/dev/null

# 设置文件权限
echo -e "${BLUE}设置文件权限...${NC}"
chmod -R 755 .

# 构建和启动
echo -e "${BLUE}构建和启动服务...${NC}"
if ! docker-compose up -d --build; then
    echo -e "${RED}构建失败！${NC}"
    exit 1
fi

# 等待服务健康检查
echo -e "${BLUE}等待服务启动...${NC}"
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:3001/health > /dev/null; then
        echo -e "${GREEN}服务已成功启动！${NC}"
        break
    fi
    echo -n "."
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo -e "${RED}服务启动超时！${NC}"
    docker-compose logs
    exit 1
fi

# 显示成功信息
echo -e "${GREEN}部署成功！${NC}"
echo -e "${YELLOW}服务访问信息：${NC}"
echo -e "  - 网络文件柜: http://localhost:3000"
echo -e "  - API 服务: http://localhost:3001"
echo -e "${YELLOW}容器信息：${NC}"
echo -e "  - 容器名称: cm-box"
echo -e "  - 存储卷: cm-box-storage"
echo -e "  - 网络: cm-box-network"
echo -e "${YELLOW}管理命令：${NC}"
echo -e "  - 查看日志: docker logs cm-box"
echo -e "  - 重启服务: docker-compose restart"
echo -e "  - 停止服务: docker-compose down"
echo -e "  - 更新服务: ./deploy.sh"

# 清理临时目录
cd - > /dev/null
rm -rf "$TEMP_DIR"