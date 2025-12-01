# Dockerized Jupyter Server for server.local

This project builds a Data Science ready Jupyter server (including PyTorch,
Pandas, SciPy, ffmpeg) and deploy it directly to a remote machine
(`server.local`) via SSH.

## Files

-   `Dockerfile`: Defines a custom Jupyter environment based on Python 3.13 (latest stable), including `ffmpeg`, `pandas`, `numpy`, `scipy`, `pytorch`.
-   `deploy.sh`: script to build and deploy the image directly to the remote server.
-   `get_token.sh`: helper script to retrieve the Jupyter login token from the remote server.

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
    Run the helper script to get the login token:
    ```bash
    ./get_token.sh
    ```
    It will output the login token.

2.  **Connect**:
    Open your browser and go to:
    `http://server.local:8888`

    Paste the token from the logs when prompted.

## Storage

The container provides two main storage locations:

### `/ephemeral` (Temporary)
-   **Type**: `tmpfs` (RAM-backed).
-   **Persistence**: **CLEARED** when the container stops or restarts.
-   **Use Case**: High-speed I/O, temporary data, intermediate processing steps.
-   **Note**: This is the fastest storage available but data is volatile.

### `/permanent` (Persistent)
-   **Type**: Bind mount to the host machine.
-   **Persistence**: Persists across container restarts.
-   **Use Case**: Jupyter notebooks, source code, final results/models.
-   **Note**: Use this only when necessary for files that must be saved.

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

# Copy files to the permanent storage
docker cp /path/to/local/file jupyter-server:/permanent

# Copy files to the ephemeral storage (tmpfs)
# Note: 'docker cp' DOES NOT work with tmpfs.

# Method 1: Tar (Best for directories or preserving attributes)
tar -c -f - /path/to/local/file | docker exec -i jupyter-server tar -x -f - -C /ephemeral

# Method 2: Cat (Best for single files)
cat /path/to/local/file | docker exec -i jupyter-server sh -c "cat > /ephemeral/filename"
```
