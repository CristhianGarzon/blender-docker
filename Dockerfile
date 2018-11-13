# Docker image for blender as python module taken from https://github.com/rbberger/blender-python
# Thanks to Richard Berger for its work

FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Cristhian Garzon <cristhianf.garzon@gmail.com>

RUN apt-get update && apt-get install -y wget sudo

RUN wget http://download.blender.org/source/blender-2.79.tar.gz -O /tmp/blender-2.79.tar.gz && \
    cd /tmp && tar xvzf /tmp/blender-2.79.tar.gz && \
    rm /tmp/blender-2.79.tar.gz && \
    /tmp/blender-2.79/build_files/build_environment/install_deps.sh --no-confirm --with-all && \
    mkdir /tmp/build && \
    cd /tmp/build &&  \
    cmake ../blender-2.79 -DWITH_PYTHON_INSTALL=OFF \
                          -DWITH_PLAYER=OFF \
                          -DWITH_PYTHON_MODULE=ON \
                          -DWITH_CODEC_SNDFILE=ON \
                          -DPYTHON_VERSION=3.5 \
                          -DWITH_OPENCOLORIO=ON \
                          -DOPENCOLORIO_ROOT_DIR=/opt/lib/ocio \
                          -DWITH_OPENIMAGEIO=ON \
                          -DOPENIMAGEIO_ROOT_DIR=/opt/lib/oiio \
                          -DWITH_CYCLES_OSL=ON \
                          -DWITH_LLVM=ON \
                          -DLLVM_VERSION=3.4 \
                          -DOSL_ROOT_DIR=/opt/lib/osl \
                          -DLLVM_ROOT_DIR=/opt/lib/llvm \
                          -DLLVM_STATIC=ON \
                          -DWITH_OPENSUBDIV=ON \
                          -DOPENSUBDIV_ROOT_DIR=/opt/lib/osd \
                          -DWITH_OPENVDB=ON \
                          -DWITH_OPENVDB_BLOSC=ON \
                          -DWITH_OPENCOLLADA=OFF \
                          -DWITH_JACK=ON \
                          -DWITH_JACK_DYNLOAD=ON \
                          -DWITH_ALEMBIC=ON \
                          -DALEMBIC_ROOT_DIR=/opt/lib/alembic \
                          -DWITH_CODEC_FFMPEG=ON \
                          -DFFMPEG_LIBRARIES='avformat;avcodec;avutil;avdevice;swscale;swresample;lzma;rt;theoradec;theora;theoraenc;vorbisenc;vorbisfile;vorbis;ogg;xvidcore;vpx;mp3lame;x264;openjpeg;openjpeg_JPWL' \
                          -DWITH_INSTALL_PORTABLE=ON \
                          -DCMAKE_INSTALL_PREFIX=/usr/lib/python3.5/site-packages && \
    make -j 4 && \
    make install && \
    rm -rf /tmp/blender-2.79 /tmp/build

# Adding linux and python libraries for libgerbv 2.6.0 development
RUN apt-get install -y nano git python3-setuptools python3-pip libsm6 libxext6 && \
    cd /tmp && git clone https://github.com/Grk0/python-libconf.git && \
    cd /tmp/python-libconf && python3 setup.py install && \
    wget https://sourceforge.net/projects/gerbv/files/gerbv/gerbv-2.6.0/gerbv-2.6.0.tar.gz/download -O /tmp/gerbv-2.6.0.tar.gz && \
    cd /tmp && tar xvzf /tmp/gerbv-2.6.0.tar.gz && rm /tmp/gerbv-2.6.0.tar.gz && \
    apt-get update && apt-get install -y libcairo2-dev gtk2.0 desktop-file-utils && \
    cd /tmp/gerbv-2.6.0 && ./configure && make && make install

# Creating Environment Variables
ENV PYTHONPATH /usr/lib/python3.5/site-packages
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib/x86_64-linux-gnu/mesa:/opt/lib/alembic-1.7.1/lib:/opt/lib/osl-1.7.5/lib:/opt/lib/osd-3.1.1/lib:/opt/lib/oiio-1.7.15/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig

# Copying source code from local machine to docker image and compile it, copy ALPHA folder in same dockerimage folder and run:
# "docker build --build-arg ARpath=ALPHA/ -t python-blender2.79 ."
ARG ARpath
COPY $ARpath /opt/ar-gerber-tool
RUN apt-get install -y libconfig-dev potrace && \
    pip3 install Pillow opencv-python && \
    cd /opt/ar-gerber-tool/src && make clean && make



