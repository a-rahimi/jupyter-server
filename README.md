# Dockerized Jupyter Server for server.local

This project allows you to build a Data Science ready Jupyter server (including PyTorch, Pandas, SciPy) and deploy it directly to a remote machine (`server.local`) via SSH.

## Files

-   `Dockerfile`: Defines a custom Jupyter environment based on Python 3.13 (latest stable), including `ffmpeg`, `pandas`, `numpy`, `scipy`, `pytorch`.
    *(Note: Python 3.14 is not yet stable, so we used 3.13. If you strictly need 3.14, it requires building from source).*
-   `deploy.sh`: script to build and deploy the image directly to the remote server.

## Prerequisites

-   **Local Machine**: Docker installed.
-   **Remote Machine (`server.local`)**: Docker installed and SSH access enabled.
-   **SSH Access**: Password-less SSH access (public key authentication) is recommended for smooth operation.

## Configuration

Open `deploy.sh` and set your remote host information if different from defaults:

```bash
REMOTE_HOST="server.local"
REMOTE_USER="ali" 
```

## Deployment

Run the deployment script:

```bash
./deploy.sh
```
What the script does:
1.  Sets the `DOCKER_HOST` environment variable to `ssh://ali@server.local`.
2.  Sends the build context (current directory) to the remote Docker daemon.
3.  Builds the image *on the remote machine*.
4.  Stops and removes any old `jupyter-server` container on the remote machine.
5.  Starts the new container on the remote machine (configured to auto-restart on reboot unless manually stopped).


## Accessing Jupyter

1.  **Find the Token**:
    View the container logs on the server to get the login token.
    You can run this locally (it queries the remote daemon):
    ```bash
    export DOCKER_HOST="ssh://ali@server.local"
    docker logs jupyter-server
    ```
    Look for a URL like: `http://127.0.0.1:8888/lab?token=...`

2.  **Connect**:
    Open your browser and go to:
    `http://server.local:8888`

    Paste the token from the logs when prompted.

## Manual Management

You can manage the remote container from your local machine by setting `DOCKER_HOST`:

```bash
export DOCKER_HOST="ssh://ali@server.local"

# Check status
docker ps

# Stop
docker stop jupyter-server

# Start
docker start jupyter-server

# Remove
docker rm jupyter-server
```
