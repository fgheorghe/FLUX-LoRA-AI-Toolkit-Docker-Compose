FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y htop wget curl mc git

RUN apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip

RUN apt-get install -y libgl1-mesa-glx

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

RUN groupadd -g 1000 -o ai
RUN useradd -m -u 1000 -g ai -o -s /bin/bash ai
RUN mkdir /flux-lora
RUN chown -R ai:ai /flux-lora

USER ai

WORKDIR flux-lora

RUN git clone https://github.com/ostris/ai-toolkit.git .
RUN git submodule update --init --recursive

RUN python3.10 -m venv venv

RUN . venv/bin/activate && pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu124

RUN . venv/bin/activate && pip install -r requirements.txt

WORKDIR ui

RUN npm install
RUN npm run build
RUN npm run update_db

CMD . ../venv/bin/activate && exec npm run start
