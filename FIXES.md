**File:** `api/.env`
**Line:** 1-2
**Issue:** Real credentials committed to the repository. REDIS_PASSWORD=supersecretpassword123 is exposed in git history, a critical security violation.
**Fix:** Deleted the file, added `.env` to `.gitignore`, removed from git tracking with `git rm --cached api/.env`

---

**File:** `api/main.py`
**Line:** 7
**Issue:** `redis.Redis(host="localhost")` — hardcoded localhost fails inside Docker containers where services communicate by service name.
**Fix:** Changed to `host=os.getenv("REDIS_HOST", "redis")`

---

**File:** `api/main.py`
**Line:** 7
**Issue:** Redis connection does not pass a password. If Redis requires authentication, all operations will be rejected with NOAUTH errors.
**Fix:** Added `password=os.getenv("REDIS_PASSWORD")` to Redis constructor

---

**File:** `api/main.py`
**Line:** 7
**Issue:** No connection timeout set. If Redis is unavailable at startup the API crashes immediately with an unhandled exception.
**Fix:** Added `socket_connect_timeout=5` to Redis constructor

---

**File:** `api/main.py`
**Line:** 19-21
**Issue:** Returns HTTP 200 with `{"error": "not found"}` when a job does not exist. Callers cannot distinguish errors from valid responses.
**Fix:** Changed to return `JSONResponse(status_code=404, content={"error": "not found"})`

---

**File:** `api/requirements.txt`
**Line:** 1-3
**Issue:** No version pins on any dependency. Builds are non-reproducible and may break silently when upstream packages release breaking changes.
**Fix:** Pinned all versions: `fastapi==0.104.1`, `uvicorn==0.24.0`, `redis==5.0.1`

---

**File:** `worker/worker.py`
**Line:** 5
**Issue:** `redis.Redis(host="localhost")` — same hardcoded localhost problem as api/main.py, will fail in Docker.
**Fix:** Changed to `host=os.getenv("REDIS_HOST", "redis")`

---

**File:** `worker/worker.py`
**Line:** 5
**Issue:** Redis connection does not pass a password, same as api/main.py.
**Fix:** Added `password=os.getenv("REDIS_PASSWORD")` to Redis constructor

---

**File:** `worker/worker.py`
**Line:** 4
**Issue:** `signal` module is imported but never used. No SIGTERM/SIGINT handler exists, so Docker cannot shut the worker down gracefully — it will be force-killed after timeout, risking job loss.
**Fix:** Added signal handlers for SIGTERM and SIGINT that set a stop flag to break the loop cleanly

---

**File:** `worker/requirements.txt`
**Line:** 1
**Issue:** No version pin on `redis` dependency. Same reproducibility problem as api/requirements.txt.
**Fix:** Pinned to `redis==5.0.1`

---

**File:** `frontend/app.js`
**Line:** 5
**Issue:** `API_URL = "http://localhost:8000"` hardcoded. The frontend container cannot reach the API via localhost in Docker.
**Fix:** Changed to `const API_URL = process.env.API_URL || "http://api:8000"`

---

**File:** `frontend/app.js`
**Line:** 29
**Issue:** Port hardcoded as 3000. Should be configurable via environment variable.
**Fix:** Changed to `app.listen(process.env.PORT || 3000, ...)`

---

**File:** `frontend/package.json`
**Line:** entire file
**Issue:** No ESLint dependency or lint script. CI pipeline will fail at lint stage.
**Fix:** Added `eslint` to devDependencies, added `"lint": "eslint app.js"` script, added `.eslintrc.json`

---

**File:** `.gitignore` (missing)
**Issue:** No .gitignore exists, which directly caused `api/.env` to be committed with real credentials.
**Fix:** Created root `.gitignore` covering `.env`, `node_modules/`, `__pycache__/`, `*.pyc`, `.coverage`, `htmlcov/`
