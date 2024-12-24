FROM archlinux

EXPOSE 8188

ENV PACMAN_FLAGS="--noconfirm --needed" VISUAL=nvim EDITOR=nvim

RUN pacman -Syu $PACMAN_FLAGS

RUN pacman -Syu git neovim locate sudo libgl base-devel less wget $PACMAN_FLAGS

RUN groupadd sudo

RUN useradd -rm -d /home/dev -s /bin/bash -g root -G sudo -u 1001 -p "$(openssl passwd -1 password)" dev

# Uncomment the following if you want the user to have root permissions:
RUN usermod -aG sudo dev
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER dev
WORKDIR /home/dev

# Install Python 3.12
RUN wget https://www.python.org/ftp/python/3.12.8/Python-3.12.8.tgz
RUN echo "304473cf367fa65e450edf4b06b55fcc Python-3.12.8.tgz" | md5sum -c - \
    && echo "Checksum is valid" || ( echo "Checksum does not match!" && exit 1 )
RUN tar -xf ./Python-3.12.8.tgz \
    && cd Python-3.12.8 \
    && ./configure --enable-optimizations \
    && make -j $(nproc)

RUN cd Python-3.12.8 \
    && sudo make install \
    && sudo ln -s /usr/local/bin/python3 /usr/local/bin/python

RUN git clone https://github.com/comfyanonymous/ComfyUI.git \
  && cd ComfyUI

WORKDIR /home/dev/ComfyUI
RUN python -m venv comfyui \
  && source comfyui/bin/activate \
  && pip install -r requirements.txt

RUN source comfyui/bin/activate \
  && cd ./custom_nodes \
  && git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
  && cd /home/dev/ComfyUI/custom_nodes/ComfyUI-Manager \
  && pip install -r requirements.txt

CMD ["bash", "-c", "source /home/dev/ComfyUI/comfyui/bin/activate && python -u main.py --port 8188 --listen"]
