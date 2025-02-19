# Use Nvidia CUDA image with Ubuntu 20.04 as base
FROM nvidia/cuda:12.4.0-devel-ubuntu20.04 as builder

# Set non-interactive mode and timezone to avoid tzdata prompt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install Python 3.10 and necessary build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3.10-venv \
    python3-pip \
    curl \
    wget \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Use Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py


# Install PyTorch, Torchvision, and Torchaudio with CUDA 12.4
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    torch==2.5.1+cu124 \
    torchvision==0.20.1+cu124 \
    torchaudio==2.5.1+cu124 \
    --index-url https://download.pytorch.org/whl/cu124

# Install SkyReel Dependencies 
RUN pip3 install --no-cache-dir \
    xformers==0.0.29.post1 \
    optimum[quanto] \
    transformers==4.46.3 \
    accelerate==1.1.1 \
    bitsandbytes==0.45.0 \
    sageattention==1.0.6 \
    git+https://github.com/huggingface/diffusers.git@464374fb87610c53b2cf81e08d3df628fada3ce4 \
    git+https://github.com/Howe2018/ParaAttention.git \
    torchao==0.7.0 \
    imageio-ffmpeg==0.5.1 \
    nvtx==0.2.10 \
    opencv-python==4.10.0.84 \
    imageio==2.36.1

# Install Jupyter and related packages explicitly
RUN pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    jupyter_server \
    jupyterlab_widgets

# Clone and setup ComfyUI
WORKDIR /
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip install --no-cache-dir -r requirements.txt

# Install ALL custom nodes during build
WORKDIR /ComfyUI/custom_nodes

# Video and Frame Processing
RUN git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone --depth 1 https://github.com/facok/ComfyUI-HunyuanVideoMultiLora.git && \
    # Workflow Tools
    git clone --depth 1 https://github.com/Amorano/Jovimetrix.git && \
    git clone --depth 1 https://github.com/sipherxyz/comfyui-art-venture.git && \
    git clone --depth 1 https://github.com/theUpsider/ComfyUI-Logic.git && \
    git clone --depth 1 https://github.com/Smirnov75/ComfyUI-mxToolkit.git && \
    git clone --depth 1 https://github.com/alt-key-project/comfyui-dream-project.git && \
    # Image Enhancement
    git clone --depth 1 https://github.com/Jonseed/ComfyUI-Detail-Daemon.git && \
    git clone --depth 1 https://github.com/ShmuelRonen/ComfyUI-ImageMotionGuider.git && \
    # Noise Tools
    git clone --depth 1 https://github.com/BlenderNeko/ComfyUI_Noise.git && \
    git clone --depth 1 https://github.com/chrisgoringe/cg-noisetools.git && \
    # Utility Nodes
    git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git && \
    git clone --depth 1 https://github.com/chrisgoringe/cg-use-everywhere.git && \
    git clone --depth 1 https://github.com/TTPlanetPig/Comfyui_TTP_Toolset.git && \
    # Special Purpose
    git clone --depth 1 https://github.com/pharmapsychotic/comfy-cliption.git && \
    git clone --depth 1 https://github.com/darkpixel/darkprompts.git && \
    git clone --depth 1 https://github.com/Koushakur/ComfyUI-DenoiseChooser.git && \
    git clone --depth 1 https://github.com/city96/ComfyUI-GGUF.git && \
    git clone --depth 1 https://github.com/giriss/comfy-image-saver.git && \
    # Additional Utilities
    git clone --depth 1 https://github.com/11dogzi/Comfyui-ergouzi-Nodes.git && \
    git clone --depth 1 https://github.com/jamesWalker55/comfyui-various.git && \
    git clone --depth 1 https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git && \
    git clone --depth 1 https://github.com/M1kep/ComfyLiterals.git && \
    git clone --depth 1 https://github.com/welltop-cn/ComfyUI-TeaCache.git && \
    git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    git clone --depth 1 https://github.com/chengzeyi/Comfy-WaveSpeed.git && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use.git && \
    git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui.git

# Install requirements for all nodes
RUN for dir in */; do \
    if [ -f "${dir}requirements.txt" ]; then \
        echo "Installing requirements for ${dir}..." && \
        pip install --no-cache-dir -r "${dir}requirements.txt" || true; \
    fi; \
    if [ -f "${dir}install.py" ]; then \
        echo "Running install script for ${dir}..." && \
        python "${dir}install.py" || true; \
    fi \
    done

# Final stage
# Final stage
FROM nvidia/cuda:12.4.0-devel-ubuntu20.04

# Set non-interactive mode and timezone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install Python 3.10 and runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3.10-venv \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    wget \
    curl \
    openssh-server \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Use Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Install Jupyter and related packages in final stage
RUN pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    jupyter_server \
    jupyterlab_widgets \
    triton \
    sageattention

# Copy Python environment from builder
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder /ComfyUI /ComfyUI

# Copy workflow files
COPY AllinOneUltra1.2.json AllinOneUltra1.3.json /ComfyUI/user/default/workflows/

# Copy scripts
COPY scripts/*.sh /
RUN chmod +x /*.sh

# Create necessary directories
RUN mkdir -p /workspace/logs /workspace/ComfyUI/models/{unet,text_encoders,clip_vision,vae,loras}

CMD ["/start.sh"]
