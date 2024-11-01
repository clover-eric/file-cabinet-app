#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"
RELEASE_DIR="cm-box-${VERSION}"

echo -e "${GREEN}开始打包网络文件柜 v${VERSION}...${NC}"

# 清理旧的发布文件
if [ -d "$RELEASE_DIR" ]; then
    echo "清理旧的发布目录..."
    rm -rf "$RELEASE_DIR"
fi
if [ -f "${RELEASE_DIR}.tar.gz" ]; then
    rm "${RELEASE_DIR}.tar.gz"
fi

# 创建发布目录
mkdir -p "${RELEASE_DIR}"

# 复制核心文件
echo "复制项目文件..."
cp -r src public server.js webpack.config.js package.json .babelrc .env "${RELEASE_DIR}/"

# 创建并初始化存储目录
mkdir -p "${RELEASE_DIR}/storage/uploads"

# 复制启动脚本
cp start-server.sh "${RELEASE_DIR}/"
chmod +x "${RELEASE_DIR}/start-server.sh"

# 创建安装脚本
cat > "${RELEASE_DIR}/install.sh" << 'EOL'
#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}开始安装网络文件柜...${NC}"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未安装 Node.js${NC}"
    echo "请先安装 Node.js (v14+)"
    exit 1
fi

# 安装依赖
echo "安装依赖..."
npm install

# 创建必要的目录
mkdir -p storage/uploads

echo -e "${GREEN}安装完成！${NC}"
echo "使用以下命令启动程序："
echo "1. 启动前端: npm start"
echo "2. 启动后端: ./start-server.sh"
EOL

chmod +x "${RELEASE_DIR}/install.sh"

# 创建 README
cat > "${RELEASE_DIR}/README.md" << EOL
# 网络文件柜 v${VERSION}

简单高效的文件管理系统。

## 系统要求

- Node.js v14 或更高版本
- 现代浏览器（Chrome、Firefox、Safari、Edge 等）

## 安装步骤

1. 解压文件：
   \`\`\`bash
   tar -xzf cm-box-${VERSION}.tar.gz
   cd cm-box-${VERSION}
   \`\`\`

2. 运行安装脚本：
   \`\`\`bash
   ./install.sh
   \`\`\`

3. 启动程序：
   - 启动前端：\`npm start\`
   - 启动后端：\`./start-server.sh\`

4. 访问程序：
   - 打开浏览器访问：http://localhost:3000

## 功能说明

- 文件上传和管理
- API 密钥生成
- 系统重置
- 响应式设计

## 注意事项

- 首次使用需要注册管理员账号
- 仅支持上传 CSV 或 TXT 文件
- 文件柜同时只能存储一个文件

## 技术支持

如有问题，请联系技术支持。
EOL

# 清理开发文件和日志
echo "清理开发文件..."
rm -rf "${RELEASE_DIR}/node_modules"
rm -rf "${RELEASE_DIR}/.git"
find "${RELEASE_DIR}" -name "*.log" -type f -delete
find "${RELEASE_DIR}" -name ".DS_Store" -type f -delete

# 打包
echo "创建发布包..."
tar -czf "${RELEASE_DIR}.tar.gz" "${RELEASE_DIR}"

# 清理临时目录
rm -rf "${RELEASE_DIR}"

echo -e "${GREEN}打包完成！${NC}"
echo -e "发布文件：${BLUE}${RELEASE_DIR}.tar.gz${NC}"
echo ""
echo "发布包包含："
echo "1. 前端源代码"
echo "2. 后端服务器"
echo "3. 安装脚本"
echo "4. 启动脚本"
echo "5. 使用说明"
echo ""
echo "客户只需要："
echo "1. 解压文件"
echo "2. 运行 ./install.sh"
echo "3. 按照提示启动程序" 