FROM bitnami/git:2.46.0-debian-12-r0 AS downloader

ARG DOWNLOAD="/download_tmp"

# Move to the temporary directory for downloading EVF-SAM weights and EVF-SAM repository
WORKDIR ${DOWNLOAD}

# Download EVF-SAM weights
RUN git clone https://huggingface.co/YxZhang/evf-sam \
    && git clone https://github.com/hustvl/EVF-SAM.git


# Select the PyTorch image based on the version of CUDA installed by the user
FROM pytorch/pytorch:2.4.0-cuda11.8-cudnn9-runtime

ARG DOWNLOAD="/download_tmp"

# Set the username
ARG USER="evf-sam-user"

# Create the host user in the container (creating the home directory of the host user is necessary when installing Python packages with a non-root user that is the host user, as it requires access permissions to $HOME)
# The ID will be mapped at runtime, so it doesn't need to be set here
RUN groupadd ${USER} \
    && useradd -d /home/${USER} -s /bin/bash -g ${USER} -m ${USER}

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y \
    # Required for installing pycocotools
    gcc \
    # Required for using cv2
    libopencv-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Change the user
USER $USER

# Move to the installation directory
WORKDIR /app

# Copy the EVF-SAM weights and repository from the downloader stage
COPY --from=downloader ${DOWNLOAD} ./

# Install EVF-SAM
RUN cd /app/EVF-SAM \
    && pip install --no-cache-dir -r requirements.txt accelerate==0.33.0

CMD ["bash"]