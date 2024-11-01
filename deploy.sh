#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"

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

# 下载必要的文件
echo -e "${BLUE}下载配置文件...${NC}"
curl -O https://raw.githubusercontent.com/clover-eric/file-cabinet-app/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/clover-eric/file-cabinet-app/main/Dockerfile

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
chmod -R 755 storage

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

# 创建管理脚本
echo -e "${BLUE}创建管理脚本...${NC}"
cat > manage.sh << 'EOL'
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

case "$1" in
    "start")
        echo -e "${GREEN}启动服务...${NC}"
        docker-compose up -d
        ;;
    "stop")
        echo -e "${GREEN}停止服务...${NC}"
        docker-compose down
        ;;
    "restart")
        echo -e "${GREEN}重启服务...${NC}"
        docker-compose restart
        ;;
    "logs")
        echo -e "${GREEN}查看日志...${NC}"
        docker logs -f cm-box
        ;;
    "status")
        echo -e "${GREEN}服务状态...${NC}"
        docker ps -f name=cm-box
        ;;
    "clean")
        echo -e "${GREEN}清理服务...${NC}"
        docker-compose down -v
        docker rmi cm-box:latest
        ;;
    *)
        echo "使用方法: ./manage.sh [命令]"
        echo "可用命令:"
        echo "  start   - 启动服务"
        echo "  stop    - 停止服务"
        echo "  restart - 重启服务"
        echo "  logs    - 查看日志"
        echo "  status  - 查看状态"
        echo "  clean   - 清理服务"
        ;;
esac
EOL

chmod +x manage.sh

echo -e "${GREEN}部署完成！${NC}"
echo -e "使用 ${BLUE}./manage.sh${NC} 管理服务" 