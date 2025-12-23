FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    COMFY_DIR=/workspace/ComfyUI

RUN apt-get update && apt-get install -y \
    git python3 python3-pip python3-venv \
    libgl1 libglib2.0-0 ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFY_DIR}

# (Pilih CUDA yang sesuai dengan base image: ini contoh cu121)
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
 && python3 -m pip install -r ${COMFY_DIR}/requirements.txt

# Install custom node: WanVideoWrapper
RUN mkdir -p ${COMFY_DIR}/custom_nodes \
 && cd ${COMFY_DIR}/custom_nodes \
 && git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
 && python3 -m pip install -r ${COMFY_DIR}/custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

# Folder yang biasanya dipersist via volume
RUN mkdir -p ${COMFY_DIR}/models ${COMFY_DIR}/output

EXPOSE 8188
WORKDIR ${COMFY_DIR}

CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
