#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"

# 仓库配置
GITHUB_REPO="git@github.com:41419350@qq.com/file-cabinet-app.git"
GITEE_REPO="git@gitee.com:41419350@qq.com/file-cabinet-app.git"

# 检查是否安装了 Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}错误: Git 未安装${NC}"
    echo "请先安装 Git: https://git-scm.com/downloads"
    exit 1
fi

# 检查是否在 Git 仓库中
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${YELLOW}初始化 Git 仓库...${NC}"
    git init
fi

# 检查远程仓库配置
setup_remote() {
    local remote_name=$1
    local repo_url=$2
    
    if ! git remote | grep -q "^${remote_name}$"; then
        echo -e "${BLUE}添加 ${remote_name} 远程仓库...${NC}"
        git remote add ${remote_name} ${repo_url}
    fi
}

# 设置远程仓库
setup_remote "github" "${GITHUB_REPO}"
setup_remote "gitee" "${GITEE_REPO}"

# 确保 .gitignore 存在并包含必要的排除项
if [ ! -f .gitignore ]; then
    echo -e "${YELLOW}创建 .gitignore 文件...${NC}"
    cat > .gitignore << 'EOL'
# 依赖
/node_modules
package-lock.json

# 构建输出
/dist
/build

# 环境变量和配置
.env
.env.local
.env.*.local

# 日志文件
*.log
npm-debug.log*

# 运行时数据
/storage
/storage/uploads

# 编辑器和IDE
.idea/
.vscode/
*.swp
*.swo
.DS_Store

# 临时文件
*.tmp
*.temp
.cache
.temp

# 系统文件
Thumbs.db
EOL
fi

# 清理临时文件和日志
echo -e "${BLUE}清理临时文件和日志...${NC}"
find . -name "*.log" -type f -delete
find . -name ".DS_Store" -type f -delete
find . -name "*.tmp" -type f -delete

# 检查工作区状态
if ! git diff --quiet || git ls-files --others --exclude-standard | grep -q .; then
    # 显示变更文件
    echo -e "${BLUE}检测到以下变更：${NC}"
    git status --short

    # 询问是否继续
    read -p "是否继续提交这些更改? (y/n): " continue_commit
    if [[ ! $continue_commit =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}操作已取消${NC}"
        exit 0
    fi

    # 添加文件到暂存区
    git add .
else
    echo -e "${YELLOW}没有检测到任何更改${NC}"
    exit 0
fi

# 提交更改
echo -e "${BLUE}提交更改...${NC}"
read -p "请输入提交信息 (默认: Update v${VERSION}): " commit_message
commit_message=${commit_message:-"Update v${VERSION}"}

git commit -m "${commit_message}"

# 推送到远程仓库
push_to_remote() {
    local remote=$1
    echo -e "${BLUE}推送到 ${remote}...${NC}"
    if git push -u ${remote} master; then
        echo -e "${GREEN}成功推送到 ${remote}${NC}"
        return 0
    else
        echo -e "${RED}推送到 ${remote} 失败${NC}"
        return 1
    fi
}

# 尝试推送到 GitHub
if ! push_to_remote "github"; then
    echo -e "${YELLOW}是否继续推送到 Gitee? (y/n): ${NC}"
    read continue_gitee
    if [[ ! $continue_gitee =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 尝试推送到 Gitee
push_to_remote "gitee"

# 询问是否创建标签
echo -e "${BLUE}是否创建发布标签 v${VERSION}? (y/n): ${NC}"
read create_tag
if [[ $create_tag =~ ^[Yy]$ ]]; then
    if git tag "v${VERSION}"; then
        git push github "v${VERSION}"
        git push gitee "v${VERSION}"
        echo -e "${GREEN}标签 v${VERSION} 已创建并推送${NC}"
    else
        echo -e "${RED}标签创建失败${NC}"
    fi
fi

echo -e "${GREEN}同步完成！${NC}"