#!/bin/bash

# Configuration
REMOTE_HOST="server.local"
REMOTE_USER="ali" 

# Set the DOCKER_HOST environment variable to point to the remote machine
# This tells the local docker client to execute commands on the remote docker daemon.
export DOCKER_HOST="ssh://$REMOTE_USER@$REMOTE_HOST"

echo "Targeting remote docker daemon at $DOCKER_HOST"

echo "Building Docker image on remote host..."
# The build context (.) is sent from local to remote.
docker build -t jupyter-server .

echo "Stopping existing container (if any)..."
docker stop jupyter-server || true
docker rm jupyter-server || true

# Get the remote user's home directory for volume mapping
# We need an absolute path for the volume mount.
echo "Resolving remote home directory..."
REMOTE_HOME=$(ssh "$REMOTE_USER@$REMOTE_HOST" "echo ~")
if [ -z "$REMOTE_HOME" ]; then
    echo "Error: Could not determine remote home directory."
    exit 1
fi

# Ensure the directory exists and is owned by the user
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_HOME/jupyter_work"

echo "Starting new container..."
docker run -d \
  --restart unless-stopped \
  -p 8888:8888 \
  -v "$REMOTE_HOME/jupyter_work:/workspace" \
  --name jupyter-server \
  jupyter-server

echo "Deployment complete! You can now access the server at http://$REMOTE_HOST:8888"
echo "To view logs/token: docker logs jupyter-server (commands now run against remote by default due to export)"
