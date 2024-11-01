#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"
REPO_URL="https://raw.githubusercontent.com/clover-eric/file-cabinet-app/main"

echo -e "${GREEN}开始部署网络文件柜 v${VERSION}...${NC}"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    echo "请先安装 Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载必要的文件
echo -e "${BLUE}下载源代码文件...${NC}"
mkdir -p src/api src/context src/components public

# 下载配置文件
curl -o docker-compose.yml "${REPO_URL}/docker-compose.yml"
curl -o Dockerfile "${REPO_URL}/Dockerfile"
curl -o package.json "${REPO_URL}/package.json"
curl -o webpack.config.js "${REPO_URL}/webpack.config.js"
curl -o server.js "${REPO_URL}/server.js"
curl -o .babelrc "${REPO_URL}/.babelrc"

# 下载源代码文件
curl -o src/index.js "${REPO_URL}/src/index.js"
curl -o src/App.js "${REPO_URL}/src/App.js"
curl -o src/index.css "${REPO_URL}/src/index.css"
curl -o src/api/api.js "${REPO_URL}/src/api/api.js"
curl -o src/context/AuthContext.js "${REPO_URL}/src/context/AuthContext.js"
curl -o public/index.html "${REPO_URL}/public/index.html"

# 创建 .env 文件
cat > .env << EOL
REACT_APP_API_URL=http://localhost:3001
REACT_APP_STORAGE_PATH=./storage
EOL

# 停止并删除旧容器
echo -e "${BLUE}清理旧的部署...${NC}"
docker-compose down -v 2>/dev/null

# 清理旧的镜像
echo -e "${BLUE}清理旧的镜像...${NC}"
docker rmi cm-box:latest 2>/dev/null

# 创建必要的目录
echo -e "${BLUE}创建必要的目录...${NC}"
mkdir -p storage/uploads

# 设置文件权限
echo -e "${BLUE}设置文件权限...${NC}"
chmod -R 755 .

# 构建新镜像
echo -e "${BLUE}构建 Docker 镜像...${NC}"
docker-compose build --no-cache

# 启动容器
echo -e "${BLUE}启动容器...${NC}"
docker-compose up -d

# 等待容器启动
echo -e "${BLUE}等待服务启动...${NC}"
sleep 5

# 检查容器状态
if [ "$(docker ps -q -f name=cm-box)" ]; then
    echo -e "${GREEN}部署成功！${NC}"
    echo -e "${YELLOW}服务访问信息：${NC}"
    echo -e "  - 网络文件柜: http://localhost:3000"
    echo -e "  - API 服务: http://localhost:3001"
    echo -e "${YELLOW}容器信息：${NC}"
    echo -e "  - 容器名称: cm-box"
    echo -e "  - 存储卷: ./storage"
    echo -e "  - 网络: cm-box-network"
    echo -e "${YELLOW}管理命令：${NC}"
    echo -e "  - 查看日志: docker logs cm-box"
    echo -e "  - 重启服务: docker-compose restart"
    echo -e "  - 停止服务: docker-compose down"
    echo -e "  - 更新服务: ./deploy.sh"
else
    echo -e "${RED}部署失败！${NC}"
    echo "请检查 Docker 日志获取详细信息："
    docker logs cm-box
    exit 1
fi

# 清理临时目录
cd - > /dev/null
rm -rf "$TEMP_DIR"