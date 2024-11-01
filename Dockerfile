# 使用多阶段构建
# 第一阶段：构建依赖
FROM node:18-alpine AS builder

# 设置淘宝 npm 镜像源以加快下载速度
RUN npm config set registry https://registry.npmmirror.com

# 设置工作目录
WORKDIR /app

# 只复制 package.json 和 package-lock.json（如果存在）
COPY package*.json ./

# 安装依赖
RUN npm install --production

# 复制源代码
COPY . .

# 构建前端
RUN npm run build

# 第二阶段：运行环境
FROM node:18-alpine

WORKDIR /app

# 从构建阶段复制必要的文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
COPY --from=builder /app/server.js .

# 创建存储目录
RUN mkdir -p storage/uploads && \
    chown -R node:node /app

# 切换到非 root 用户
USER node

# 暴露端口
EXPOSE 3000 3001

# 启动命令
CMD ["node", "server.js"] 