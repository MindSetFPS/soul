# Docker — build and run

This document shows recommended ways to build and run Soul using the project Dockerfile.

Prerequisites

- Docker installed on your machine.

Build

- Build the image from the project root:

  ```sh
  docker build -t soul:latest .
  ```

- On non-amd64 machines (e.g. Apple Silicon), add the platform flag:

  ```sh
  docker build --platform linux/amd64 -t soul:latest .
  ```

Quick start (persistent SQLite database)

- Create a local folder for the database, then run the container and set the DB path via environment variable:

  ```sh
  mkdir -p ./data && touch ./data/soul.db
  docker run --name soul -p 8000:8000 -v "$(pwd)/data":/data -e DB=/data/soul.db -d soul:latest
  ```

- Verify the server is running:

  ```sh
  curl http://localhost:8000/api/tables
  ```

Auth mode and initial user (example)

- Use environment variables to enable auth and seed an initial user and token secret:

  ```sh
  docker run --name soul -p 8000:8000 -v "$(pwd)/data":/data \
    -e DB=/data/soul.db \
    -e AUTH=true \
    -e TOKEN_SECRET='replace-with-a-secret' \
    -e INITIAL_USER_USERNAME='admin' \
    -e INITIAL_USER_PASSWORD='P@ssw0rd' \
    -d soul:latest
  ```

Using an .env file

- Soul loads environment variables from a `.env` file in the project root (or you can pass an explicit path via the `--env` flag).
- With Docker you can either pass variables with `--env-file .env` or mount the file into the container at `/app/.env` (the app's working directory):

  ```sh
  docker run --name soul -p 8000:8000 -v "$(pwd)/data":/data --env-file .env -d soul:latest
  # or
  docker run --name soul -p 8000:8000 -v "$(pwd)/data":/data -v "$(pwd)/.env":/app/.env:ro -d soul:latest
  ```

Docker Compose example

- Minimal docker-compose service:

  ```yaml
  version: '3.8'
  services:
    soul:
      build: .
      image: soul:latest
      ports:
        - "8000:8000"
      volumes:
        - ./data:/data
        - ./.env:/app/.env:ro
      environment:
        - DB=/data/soul.db
        - AUTH=true
        - TOKEN_SECRET=replace-with-a-secret
  ```

Stopping, removing and logs

- View logs:

  ```sh
  docker logs -f soul
  ```

- Stop and remove:

  ```sh
  docker stop soul && docker rm soul
  ```

Troubleshooting notes

- The Dockerfile installs build tools (python3 and build-base) so native modules like `better-sqlite3` can compile during `npm ci`.
- Ensure the host `./data` folder is writable by the container so SQLite can write the DB file.
- To change the internal listening port, set CORE_PORT in the environment and map it with `-p host_port:CORE_PORT`.
- If you need to pass runtime CLI options instead of env vars, override the container command, e.g.:

  ```sh
  docker run --rm soul:latest node src/server.js -d /data/soul.db -a --ts=replace-with-a-secret
  ```

That's it — the app should be reachable at http://localhost:8000/ (API docs: /api/docs).
