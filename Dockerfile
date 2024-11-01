# 基础阶段：安装依赖
FROM node:18-alpine AS base

# 设置环境变量
ENV NODE_ENV=production \
    NPM_CONFIG_LOGLEVEL=error \
    NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# 设置工作目录
WORKDIR /app

# 只复制 package.json 和 package-lock.json
COPY package*.json ./

# 构建阶段：构建前端
FROM base AS builder

# 设置为开发环境以安装所有依赖
ENV NODE_ENV=development

# 安装所有依赖
RUN npm install --no-audit --no-cache

# 安装全局依赖
RUN npm install -g webpack webpack-cli

# 安装特定的开发依赖
RUN npm install --save-dev \
    webpack \
    webpack-cli \
    webpack-dev-server \
    babel-loader \
    @babel/core \
    @babel/preset-react \
    @babel/preset-env \
    css-loader \
    style-loader \
    html-webpack-plugin \
    dotenv-webpack \
    @babel/plugin-transform-runtime

# 复制源代码
COPY . .

# 创建 .env 文件
RUN echo "REACT_APP_API_URL=http://localhost:3001" > .env && \
    echo "REACT_APP_STORAGE_PATH=./storage" >> .env

# 构建前端
RUN npm run build

# 生产阶段：最终镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制必要的文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
COPY --from=builder /app/server.js .

# 创建存储目录并设置权限
RUN mkdir -p storage/uploads && \
    chown -R node:node /app

# 使用非 root 用户
USER node

# 环境变量
ENV NODE_ENV=production \
    PORT=3001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# 暴露端口
EXPOSE 3000 3001

# 启动命令
CMD ["npm", "run", "prod"] 