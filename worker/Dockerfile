# Builder stage
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.11-slim

WORKDIR /app

# Install procps with pinned version for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps=2:4.0.2-3 \
    && rm -rf /var/lib/apt/lists/*

# Run as non-root user
RUN useradd -m -s /bin/bash appuser

# Copy installed dependencies
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD pgrep -f worker.py || exit 1

CMD ["python", "worker.py"]
