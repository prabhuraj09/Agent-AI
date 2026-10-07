# ========================================================
# Stage 1: Build Frontend (Vite + React)
# ========================================================
FROM node:20-alpine AS client-builder
WORKDIR /app/client

COPY client/package*.json ./
RUN npm ci

COPY client/ ./
RUN npm run build

# ========================================================
# Stage 2: Server & Runtime
# ========================================================
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

# Install server production dependencies
COPY server/package*.json ./server/
WORKDIR /app/server
RUN npm ci --only=production

# Copy server code
COPY server/ ./

# Copy built frontend assets from stage 1 into client/dist
COPY --from=client-builder /app/client/dist /app/client/dist

EXPOSE 5000

USER node

CMD ["node", "src/server.js"]
