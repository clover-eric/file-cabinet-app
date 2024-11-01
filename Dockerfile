# 基础阶段：安装依赖
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com && \
    npm install

# 构建阶段：构建前端
FROM base AS builder
COPY . .
RUN npm run build

# 生产阶段：最终镜像
FROM node:18-alpine
WORKDIR /app

# 只复制生产环境需要的文件
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