# 基础阶段：安装依赖
FROM node:18-alpine AS base

# 设置淘宝 npm 镜像源和其他优化配置
RUN npm config set registry https://registry.npmmirror.com && \
    npm config set disturl https://npmmirror.com/dist && \
    npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass && \
    npm config set puppeteer_download_host https://npmmirror.com/mirrors && \
    npm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver && \
    npm config set operadriver_cdnurl https://npmmirror.com/mirrors/operadriver && \
    npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs && \
    npm config set electron_mirror https://npmmirror.com/mirrors/electron/ && \
    npm config set python_mirror https://npmmirror.com/mirrors/python && \
    npm config set cache-lock-retries 1000 && \
    npm config set cache-lock-wait 60000 && \
    npm config set network-timeout 60000

WORKDIR /app

# 只复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖，使用 npm ci 而不是 npm install
RUN npm ci --only=production

# 构建阶段：构建前端
FROM base AS builder

# 复制源代码
COPY . .

# 构建前端
RUN npm run build

# 生产阶段：最终镜像
FROM node:18-alpine

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