#!/bin/bash

# 颜色配置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"

# 仓库配置 (修改为正确的仓库地址)
GITHUB_REPO="git@github.com:clover-eric/file-cabinet-app.git"
GITEE_REPO="git@gitee.com:clover-eric/file-cabinet-app.git"

# 检查 Git 配置
check_git_config() {
    if [ -z "$(git config --get user.name)" ] || [ -z "$(git config --get user.email)" ]; then
        echo -e "${YELLOW}Git 用户信息未配置，请设置：${NC}"
        read -p "输入 Git 用户名: " git_user
        read -p "输入 Git 邮箱: " git_email
        git config --global user.name "$git_user"
        git config --global user.email "$git_email"
    fi
}

# 检查 SSH 密钥
check_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "${YELLOW}未找到 SSH 密钥，是否生成新的密钥？(y/n): ${NC}"
        read generate_key
        if [[ $generate_key =~ ^[Yy]$ ]]; then
            ssh-keygen -t rsa -b 4096 -C "$(git config --get user.email)"
            echo -e "${GREEN}SSH 密钥已生成${NC}"
            echo -e "${YELLOW}请将以下公钥添加到 GitHub 和 Gitee：${NC}"
            cat ~/.ssh/id_rsa.pub
            echo -e "${YELLOW}按任意键继续...${NC}"
            read -n 1
        fi
    fi
}

# 检查远程仓库配置
setup_remote() {
    local remote_name=$1
    local repo_url=$2
    
    if git remote | grep -q "^${remote_name}$"; then
        echo -e "${BLUE}更新 ${remote_name} 远程仓库地址...${NC}"
        git remote set-url ${remote_name} ${repo_url}
    else
        echo -e "${BLUE}添加 ${remote_name} 远程仓库...${NC}"
        git remote add ${remote_name} ${repo_url}
    fi
}

# 测试 SSH 连接
test_ssh_connection() {
    local remote=$1
    local host
    
    case $remote in
        "github")
            host="github.com"
            ;;
        "gitee")
            host="gitee.com"
            ;;
    esac
    
    echo -e "${BLUE}测试 ${remote} SSH 连接...${NC}"
    if ssh -T git@${host} 2>&1 | grep -q "success\|成功\|authenticated"; then
        echo -e "${GREEN}${remote} SSH 连接成功${NC}"
        return 0
    else
        echo -e "${RED}${remote} SSH 连接失败${NC}"
        return 1
    fi
}

# 主程序开始
echo -e "${BLUE}开始同步代码...${NC}"

# 检查 Git 安装
if ! command -v git &> /dev/null; then
    echo -e "${RED}错误: Git 未安装${NC}"
    echo "请先安装 Git: https://git-scm.com/downloads"
    exit 1
fi

# 检查 Git 配置和 SSH 密钥
check_git_config
check_ssh_key

# 检查是否在 Git 仓库中
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${YELLOW}初始化 Git 仓库...${NC}"
    git init
fi

# 设置远程仓库
setup_remote "github" "${GITHUB_REPO}"
setup_remote "gitee" "${GITEE_REPO}"

# 测试 SSH 连接
test_ssh_connection "github" || {
    echo -e "${RED}GitHub SSH 连接失败，请检查 SSH 配置${NC}"
    exit 1
}

test_ssh_connection "gitee" || {
    echo -e "${RED}Gitee SSH 连接失败，请检查 SSH 配置${NC}"
    exit 1
}

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
else
    echo -e "${YELLOW}没有检测到任何更改${NC}"
    exit 0
fi

# 推送代码
for remote in "github" "gitee"; do
    echo -e "${BLUE}推送到 ${remote}...${NC}"
    if git push -u ${remote} main; then
        echo -e "${GREEN}成功推送到 ${remote}${NC}"
    else
        echo -e "${RED}推送到 ${remote} 失败${NC}"
        read -p "是否继续? (y/n): " continue_push
        if [[ ! $continue_push =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
done

# 创建标签
echo -e "${BLUE}是否创建发布标签 v${VERSION}? (y/n): ${NC}"
read create_tag
if [[ $create_tag =~ ^[Yy]$ ]]; then
    if git tag "v${VERSION}"; then
        for remote in "github" "gitee"; do
            if git push ${remote} "v${VERSION}"; then
                echo -e "${GREEN}标签已推送到 ${remote}${NC}"
            else
                echo -e "${RED}推送标签到 ${remote} 失败${NC}"
            fi
        done
    else
        echo -e "${RED}标签创建失败${NC}"
    fi
fi

echo -e "${GREEN}同步完成！${NC}"