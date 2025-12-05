# Particle41 DevOps Challenge

## Task 1 – SimpleTimeService Application

A minimal FastAPI service returning the current timestamp and client IP.

### Build & Run Locally

```bash
cd app
docker build -t <your-dockerhub-username>/simple-time-service:latest .
docker run -p 8000:8000 <your-dockerhub-username>/simple-time-service:latest

