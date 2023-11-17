FROM balenalib/raspberrypi3-debian-python:3.9.16-build

RUN [ "cross-build-start" ]

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" > /etc/apt/sources.list.d/coral-edgetpu.list
RUN echo "deb https://packages.cloud.google.com/apt coral-cloud-stable main" > /etc/apt/sources.list.d/coral-cloud.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --allow-downgrades \
    git \
    # numpy deps:
    libatlas-base-dev libgfortran5 libopenblas-dev \
    # OpenCV deps:
    ffmpeg libsm6 libxext6 

RUN pip3 install --upgrade pip wheel setuptools

# Hold numpy at 1.19.2 while installing tflite-runtime for dependency purposes
RUN pip3 install --extra-index-url https://www.piwheels.org/simple --only-binary=:all: -U opencv-python-headless>=4.5.4 numpy==1.19.2 matplotlib pillow tflite_support

# TFLite-runtime 2.9.0 for ARMv7
WORKDIR /tmp
RUN curl -OL https://github.com/PINTO0309/TensorflowLite-bin/releases/download/v2.9.0/tflite_runtime-2.9.0-cp39-none-linux_armv7l.whl
RUN pip3 install --only-binary=:all: tflite_runtime-2.9.0-cp39-none-linux_armv7l.whl

# Seems to work OK to install newer numpy after tflite-runtime is safely installed
RUN pip3 install --extra-index-url https://www.piwheels.org/simple --only-binary=:all: -U numpy

# Add build ncnn
RUN git clone https://github.com/Tencent/ncnn.git \
    cd ncnn \
    git submodule update --remote --recursive \
    mkdir -p build \
    cd build \
    cmake -DCMAKE_BUILD_TYPE=Release -DNCNN_VULKAN=ON -DNCNN_BUILD_EXAMPLES=ON -DCMAKE_TOOLCHAIN_FILE=../toolchains/pi3.toolchain.cmake .. \
    make -j$(nproc)

RUN [ "cross-build-end" ]

CMD ["/bin/bash"]