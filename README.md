# 网络文件柜系统 (Network File Cabinet)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/clover-eric/file-cabinet-app/releases)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://www.docker.com/)

一个基于 React 和 Node.js 的现代化文件管理系统，提供简单高效的文件存储和管理解决方案。

## 🚀 一键部署

### Docker 部署

## 功能特点

- 🔐 安全的用户认证系统
- 📁 文件上传和管理
- 🔑 API 密钥管理
- 🔄 自动同步功能
- 📱 响应式设计
- 🚀 快速部署选项

## 系统要求

- Node.js v14 或更高版本
- npm v6 或更高版本
- 现代浏览器（Chrome、Firefox、Safari、Edge 等）
- Docker（可选，用于容器化部署）

## 快速开始

### 方法一：本地开发
@
1. 克隆仓库 

bash

git clone <repository-url>

cd file-cabinet-app

2. 安装依赖

bash

npm install

3. 启动开发服务器

bash

# 启动前端服务

npm start

# 启动后端服务（新终端）

./start-server.sh

\### 方法二：Docker 部署

1. 使用部署脚本

bash

./deploy.sh

2. 使用管理脚本

bash

./manage.sh start # 启动服务

./manage.sh stop # 停止服务

./manage.sh status # 查看状态

\## 项目结构

file-cabinet-app/

├── src/ # 源代码目录

│ ├── components/ # React 组件

│ ├── context/ # 上下文管理

│ ├── api/ # API 配置

│ └── index.js # 入口文件

├── public/ # 静态资源

├── server.js # 后端服务器

├── docker/ # Docker 配置

└── scripts/ # 部署脚本

\## 可用脚本

\- `npm start`: 启动开发服务器

\- `npm run build`: 构建生产版本

\- `./deploy.sh`: Docker 部署

\- `./git-sync.sh`: 代码同步到 GitHub 和 Gitee

\- `./release.sh`: 创建发布包

\- `./restart.sh`: 重启服务

\## 环境变量

创建 `.env` 文件：

env

REACT_APP_API_URL=http://localhost:3001

REACT_APP_STORAGE_PATH=./storage

\## 部署选项

\### 1. 标准部署

使用 `release.sh` 创建发布包：

bash

./release.sh

\### 2. Docker 部署

使用 Docker Compose 进行容器化部署：

bash

./deploy.sh

\### 3. 开发环境

直接运行开发服务器：

bash

npm start

\## 代码同步

使用 `git-sync.sh` 同步到多个仓库：

bash

./git-sync.sh

\## 安全说明

\- 所有 API 请求都需要认证

\- 文件上传大小限制：10MB

\- 支持的文件类型：CSV、TXT

\- 自动会话超时处理

\## 故障排除

1. 端口冲突

bash

./restart.sh

2. 清理缓存

bash

rm -rf node_modules

npm install

3. Docker 问题

bash

./manage.sh clean

./deploy.sh

\## 维护说明

\- 定期检查日志文件

\- 备份 storage 目录

\- 更新依赖包

\- 监控服务器状态

\## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

\## 版本历史

\- v1.0.0

 \- 初始版本发布

 \- 基本文件管理功能

 \- 用户认证系统

\## 许可证

[MIT License](LICENSE)

\## 技术支持

如有问题，请联系技术支持或提交 Issue。

\## 作者

[Your Name] - 初始开发者

\## 致谢

\- React 团队

\- Material-UI

\- Docker 社区

\- 所有贡献者

这个 README 文件包含了：

项目概述

功能特点

安装说明

使用方法

部署选项

故障排除

维护指南

安全说明

版本历史

许可信息