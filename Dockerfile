FROM archlinux

EXPOSE 8188

ENV PACMAN_FLAGS="--noconfirm --needed"

RUN pacman -Syu $PACMAN_FLAGS

RUN pacman -Syu git neovim locate sudo python-pip $PACMAN_FLAGS

RUN groupadd sudo

RUN useradd -rm -d /home/dev -s /bin/bash -g root -G sudo -u 1001 -p "$(openssl passwd -1 password)" dev
RUN usermod -aG sudo dev
USER dev
WORKDIR /home/dev

RUN git clone https://github.com/comfyanonymous/ComfyUI.git \
  && cd ComfyUI

WORKDIR /home/dev/ComfyUI
RUN python -m venv comfyui \
  && source comfyui/bin/activate \
  && pip install -r requirements.txt \
  && cd /home/dev/ComfyUI/custom_nodes \
  && git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
  && cd /home/dev/ComfyUI/custom_nodes/ComfyUI-Manager \
  && pip install -r requirements.txt

#ENV NVIDIA_VISIBLE_DEVICES=all PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS="" PATH=$PATH:/home/dev/.local/bin
#CMD python3 -u main.py --listen --port 8188 ${CLI_ARGS}
CMD ["bash", "-c", "source /home/dev/ComfyUI/comfyui/bin/activate && python -u main.py --port 8188 --listen"]
