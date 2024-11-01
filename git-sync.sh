#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"

# 仓库配置 (修改为你的实际仓库地址)
GITHUB_REPO="git@github.com:clover-eric/file-cabinet-app.git"
GITEE_REPO="git@gitee.com:clover-eric/file-cabinet-app.git"

# 检查并配置 Git
echo -e "${BLUE}检查 Git 配置...${NC}"
if [ -z "$(git config --get user.name)" ]; then
    read -p "请输入 Git 用户名: " git_user
    git config --global user.name "$git_user"
fi

if [ -z "$(git config --get user.email)" ]; then
    read -p "请输入 Git 邮箱: " git_email
    git config --global user.email "$git_email"
fi

# 检查是否在 Git 仓库中
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${YELLOW}初始化 Git 仓库...${NC}"
    git init
    git add .
    git commit -m "Initial commit"
fi

# 检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "HEAD" ] || [ -z "$CURRENT_BRANCH" ]; then
    echo -e "${YELLOW}创建并切换到 main 分支...${NC}"
    git checkout -b main
fi

# 配置远程仓库
echo -e "${BLUE}配置远程仓库...${NC}"
# GitHub
if ! git remote | grep -q "^github$"; then
    git remote add github "${GITHUB_REPO}"
else
    git remote set-url github "${GITHUB_REPO}"
fi

# Gitee
if ! git remote | grep -q "^gitee$"; then
    git remote add gitee "${GITEE_REPO}"
else
    git remote set-url gitee "${GITEE_REPO}"
fi

# 显示当前配置
echo -e "${BLUE}当前 Git 配置：${NC}"
echo "用户名: $(git config --get user.name)"
echo "邮箱: $(git config --get user.email)"
echo -e "${BLUE}远程仓库：${NC}"
git remote -v

# 检查工作区状态
if ! git diff --quiet || git ls-files --others --exclude-standard | grep -q .; then
    echo -e "${BLUE}检测到以下变更：${NC}"
    git status --short
    
    read -p "是否继续提交这些更改? (y/n): " continue_commit
    if [[ ! $continue_commit =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}操作已取消${NC}"
        exit 0
    fi
    
    git add .
    
    read -p "请输入提交信息 (默认: Update v${VERSION}): " commit_message
    commit_message=${commit_message:-"Update v${VERSION}"}
    
    git commit -m "${commit_message}"
fi

# 推送代码
push_to_remote() {
    local remote=$1
    echo -e "${BLUE}推送到 ${remote}...${NC}"
    if git push -u ${remote} main --force; then
        echo -e "${GREEN}成功推送到 ${remote}${NC}"
        return 0
    else
        echo -e "${RED}推送到 ${remote} 失败${NC}"
        return 1
    fi
}

# 推送到 GitHub
if ! push_to_remote "github"; then
    echo -e "${YELLOW}是否继续推送到 Gitee? (y/n): ${NC}"
    read continue_gitee
    if [[ ! $continue_gitee =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 推送到 Gitee
push_to_remote "gitee"

# 创建标签
echo -e "${BLUE}是否创建发布标签 v${VERSION}? (y/n): ${NC}"
read create_tag
if [[ $create_tag =~ ^[Yy]$ ]]; then
    if git tag "v${VERSION}"; then
        git push github "v${VERSION}" || echo -e "${RED}推送标签到 GitHub 失败${NC}"
        git push gitee "v${VERSION}" || echo -e "${RED}推送标签到 Gitee 失败${NC}"
        echo -e "${GREEN}标签 v${VERSION} 已创建${NC}"
    else
        echo -e "${RED}标签创建失败${NC}"
    fi
fi

echo -e "${GREEN}同步完成！${NC}"