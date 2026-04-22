# Job Processing System

Welcome to the HNG14 Stage 2 DevOps Task repository. This project is a containerized, full-stack job processing system demonstrating best practices in Docker, CI/CD, and infrastructure management.

## Live URL
**Live URL:** https://haidara.mooo.com

## Project Overview

The application comprises 4 intercommunicating services:

1. **Frontend (Node.js/Express):** User-facing application on port 3000 where users submit and track jobs.
2. **API (Python/FastAPI):** Internal REST API running on port 8000 that creates jobs and serves status updates.
3. **Worker (Python):** Background worker process that continuously polls the Redis queue to process pending jobs.
4. **Redis:** Shared in-memory data store acting as the message broker between the API and Worker.

## Architecture Diagram

```ascii
                      +---------------+
User (Browser) -----> |   Frontend    | (Node.js :3000)
                      +-------+-------+
                              |
                     (HTTP POST / GET)
                              |
                      v-------+-------v
                      |      API      | (FastAPI :8000)
                      +-------+-------+
                              |
                      (Push Job to Queue)
                              |
                      v-------+-------v
                      |     Redis     | (Queue)
                      +-------+-------+
                              |
                     (Pop Job via brpop)
                              |
                      ^-------+-------^
                      |     Worker    | (Python Background)
                      +---------------+
```

## Prerequisites
- Docker >= 24
- Docker Compose >= 2.20
- Git

## Setup from Scratch
1. **Clone the repository:**
   ```bash
   git clone https://github.com/aleeyutk/hng14-stage2-devops.git
   cd hng14-stage2-devops
   ```
2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Open .env and fill in secure passwords/values
   ```
3. **Start the stack:**
   ```bash
   docker-compose up -d
   ```
4. **Verify health:**
   You can verify all services are running smoothly by checking the status of the containers and their internal healthchecks:
   ```bash
   docker-compose ps
   ```
   All services should eventually show `(healthy)`.

## Endpoints Summary

### Frontend (User-Facing)
- `POST /submit`
  - Submits a job request directly to the API via backend-to-backend communication.
  - Expected Response Code: `200 OK`
  - Response Body: `{"job_id": "uuid..."}`

- `GET /status/:id`
  - Retrieves the current status of the specified job ID.
  - Expected Response Code: `200 OK`
  - Response Body: `{"job_id": "uuid...", "status": "queued|completed"}`

### API (Internal)
- `POST /jobs`
  - Pushes a new job ID onto the Redis message queue and initializes the status.
  - Expected Response Code: `200 OK`
  - Response Body: `{"job_id": "uuid..."}`

- `GET /jobs/:id`
  - Fetches the status of a job from the Redis Hash.
  - Expected Response Code: `200 OK` or `404 Not Found` (if missing).
  - Response Body: `{"job_id": "...", "status": "..."}` or `{"error": "not found"}`

## CI/CD Pipeline

The project utilizes a strict, 6-stage GitHub Actions pipeline ensuring code quality and deployment reliability. Each stage blocks the next on failure:
1. **Lint Stage:** Runs `flake8`, `eslint`, and `hadolint` to guarantee code and Dockerfile compliance.
2. **Test Stage:** Executes `pytest` with `pytest-cov` using a mocked Redis backend (`fakeredis`) and captures coverage.
3. **Build Stage:** Builds all 3 custom Docker images and pushes them to a local service registry for downstream use.
4. **Security Scan Stage:** Downloads the built images and scans them aggressively with Aqua Trivy for CRITICAL vulnerabilities.
5. **Integration Test Stage:** Brings up the entire stack using docker-compose and verifies correct E2E function between frontend, API, worker, and Redis.
6. **Deploy Stage:** Triggered only on `main` branch pushes. Initiates a rolling update directly to the production server via SSH.

## Rolling Deployment Strategy
Deployment utilizes the docker `run` and healthcheck commands to achieve zero-downtime rolling updates:
1. Updates are pulled and the new image is built dynamically on the server.
2. A temporary container is spawned alongside the old one.
3. The server polls the healthcheck of the new container.
4. Only upon healthcheck success does the CI kill the old container and rename the temporary one to take its place.

## Local Testing
To run the automated tests locally:
```bash
# Setup virtual environment
python3 -m venv venv
source venv/bin/activate
# Install requirements
pip install -r api/requirements.txt
pip install pytest pytest-cov fakeredis httpx
# Run tests
PYTHONPATH=. pytest api/tests/
```
