FROM python:3.14-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies (including ffmpeg)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter and Data Science packages
# We pin versions or use --no-cache-dir to keep image lean
RUN pip install --no-cache-dir \
    jupyterlab \
    notebook \
    pandas \
    numpy \
    scipy \
    torch \
    torchvision \
    torchaudio \
    matplotlib \
    seaborn

# Create a user to avoid running as root
ARG USERNAME=jupyter
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Setup workspace and permissions
WORKDIR /ephemeral
RUN chown $USERNAME:$USERNAME /ephemeral

USER $USERNAME

# Expose the default Jupyter port
EXPOSE 8888

# Launch Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
