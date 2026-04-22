# Builder stage - install all deps including devDependencies
FROM node:20-alpine AS builder

WORKDIR /build

COPY package.json package-lock.json* ./
RUN npm install

COPY . .

# Final stage - production only
FROM node:20-alpine

WORKDIR /app

RUN adduser -D appuser

COPY package.json package-lock.json* ./
RUN npm install --omit=dev

COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

EXPOSE 3000

CMD ["node", "app.js"]
