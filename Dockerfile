FROM archlinux

EXPOSE 8188

ENV PACMAN_FLAGS="--noconfirm --needed" VISUAL=nvim EDITOR=nvim

RUN pacman -Syu $PACMAN_FLAGS

RUN pacman -Syu git neovim plocate libgl base-devel less wget $PACMAN_FLAGS

RUN useradd -rm -d /home/dev -s /bin/bash -u 1001 -p "$(openssl passwd -1 password)" dev
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
    && make install \
    && ln -s /usr/local/bin/python3 /usr/local/bin/python

USER dev
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

WORKDIR /home/dev
COPY entrypoint.sh /home/dev/

# Install CUDA and gcc
USER root
RUN wget https://archive.archlinux.org/packages/g/gcc/gcc-13.2.1-6-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/c/cuda/cuda-12.6.3-1-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-13.2.1-6-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/c/cmake/cmake-3.29.2-1-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/j/jsoncpp/jsoncpp-1.9.5-2-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/c/cppdap/cppdap-1.58.0-1-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/c/ccache/ccache-4.9.1-1-x86_64.pkg.tar.zst
RUN wget https://archive.archlinux.org/packages/g/glibc/glibc-2.40-1-x86_64.pkg.tar.zst

RUN pacman -U ${PACMAN_FLAGS} gcc-13.2.1-6-x86_64.pkg.tar.zst gcc-libs-13.2.1-6-x86_64.pkg.tar.zst cmake-3.29.2-1-x86_64.pkg.tar.zst jsoncpp-1.9.5-2-x86_64.pkg.tar.zst cppdap-1.58.0-1-x86_64.pkg.tar.zst ccache-4.9.1-1-x86_64.pkg.tar.zst glibc-2.40-1-x86_64.pkg.tar.zst
RUN pacman -U ${PACMAN_FLAGS} /home/dev/cuda-12.6.3-1-x86_64.pkg.tar.zst
ENV PATH=$PATH:/opt/cuda/bin

# Install SageAttention (optional)
#RUN git clone https://github.com/thu-ml/SageAttention.git \
#    && cd SageAttention \
#    && python setup.py install

# Clean-up
WORKDIR /home/dev/
RUN rm cuda-12.6.3-1-x86_64.pkg.tar.zst gcc-13.2.1-6-x86_64.pkg.tar.zst gcc-libs-13.2.1-6-x86_64.pkg.tar.zst cmake-3.29.2-1-x86_64.pkg.tar.zst jsoncpp-1.9.5-2-x86_64.pkg.tar.zst cppdap-1.58.0-1-x86_64.pkg.tar.zst ccache-4.9.1-1-x86_64.pkg.tar.zst glibc-2.40-1-x86_64.pkg.tar.zst
RUN rm -rf /home/dev/Python-3.12.8*

USER dev
WORKDIR /home/dev/ComfyUI
CMD ["bash", "-c", "/home/dev/entrypoint.sh"]
