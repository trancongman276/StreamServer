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
    libatlas-base-dev libgfortran5 \
    # OpenCV deps:
    libatlas3-base \
    libharfbuzz0b \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpixman-1-0 \
    libtiff5 \
    libvorbisenc2 \
    libvorbisfile3 \
    libxcb-render0 \
    libxcb-shm0 \
    libxrender1

RUN pip3 install --upgrade pip wheel setuptools

# Hold numpy at 1.19.2 while installing tflite-runtime for dependency purposes
RUN pip3 install --extra-index-url https://www.piwheels.org/simple --only-binary=:all: -U opencv-python-headless>=4.5.4 numpy==1.19.2 matplotlib pillow tflite_support

# TFLite-runtime 2.9.0 for ARMv7
WORKDIR /tmp
RUN curl -OL https://github.com/PINTO0309/TensorflowLite-bin/releases/download/v2.9.0/tflite_runtime-2.9.0-cp37-none-linux_armv7l.whl
RUN pip3 install --only-binary=:all: tflite_runtime-2.9.0-cp37-none-linux_armv7l.whl

# Seems to work OK to install newer numpy after tflite-runtime is safely installed
RUN pip3 install --extra-index-url https://www.piwheels.org/simple --only-binary=:all: -U numpy

# USER root

# RUN mkdir -p /deepdish/detectors/yolo
# RUN wget -O /deepdish/detectors/yolo/yolo.h5 https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/yolo.h5

# Create 'user' for running things
# ARG USER_ID
# ARG GROUP_ID

# RUN addgroup --gid $GROUP_ID user
# RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid 0 user
# RUN adduser user plugdev
# RUN adduser user video

# RUN mkdir -p /work
# RUN chown -R user:user /work # /yolo

# Allow password-less 'root' login with 'su'
# RUN passwd -d root
# RUN sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth

# RUN echo '#!/bin/bash\nPYTHONPATH=/deepdish:$PYTHONPATH DEEPDISHHOME=/deepdish python3 /deepdish/deepdish.py $@' > /usr/bin/deepdish.sh
# COPY yolov5-demo.sh /usr/bin
# COPY tflite-demo.sh /usr/bin

# RUN (cd /usr/bin; chmod +x deepdish.sh yolov5-demo.sh tflite-demo.sh)

# COPY *.py /deepdish/
# COPY detectors/mobilenet/* /deepdish/detectors/mobilenet/
# COPY detectors/efficientdet_lite0/* /deepdish/detectors/efficientdet_lite0/
# COPY detectors/yolov5/* /deepdish/detectors/yolov5/
# COPY encoders/* /deepdish/encoders/
# COPY yolo3/*.py /deepdish/yolo3/
# COPY tools/*.py /deepdish/tools/
# COPY deep_sort/*.py /deepdish/deep_sort/
# COPY deepdish/*.py /deepdish/deepdish/
# COPY bicycle_test1.mp4 /deepdish

RUN [ "cross-build-end" ]

CMD ["/bin/bash"]