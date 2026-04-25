FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

FROM node:20-alpine AS production
WORKDIR /app

RUN apk update && \
    apk upgrade && \
    npm install -g npm@latest && \
    npm cache clean --force && \
    rm -rf /var/cache/apk/*

RUN addgroup -S wellnest && adduser -S wellnest -G wellnest

COPY package*.json ./
RUN npm install --omit=dev

COPY --from=builder /app/src ./src
RUN chown -R wellnest:wellnest /app

USER wellnest

EXPOSE 3003

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:3003/health || exit 1

CMD ["node", "src/index.js"]
