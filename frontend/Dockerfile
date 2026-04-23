# Stage 1: builder
FROM node:20-alpine AS builder

WORKDIR /build

COPY package.json package-lock.json* ./
RUN npm install

COPY . .

# Stage 2: final
FROM node:20-alpine AS final

WORKDIR /app

RUN useradd -r -s /bin/false appuser 2>/dev/null || adduser -S -H appuser

COPY package.json package-lock.json* ./
RUN npm install --omit=dev

COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

EXPOSE 3000

CMD ["node", "app.js"]
