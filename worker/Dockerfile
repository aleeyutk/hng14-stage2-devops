# Stage 1: builder
FROM python:3.13-alpine AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: final
FROM python:3.13-alpine AS final

WORKDIR /app

RUN useradd -r -s /bin/false appuser 2>/dev/null || adduser -S -H appuser

COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import redis, os; r = redis.Redis(host=os.getenv('REDIS_HOST','redis'), port=6379, password=os.getenv('REDIS_PASSWORD')); r.ping()" || exit 1

CMD ["python", "worker.py"]
