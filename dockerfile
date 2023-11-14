FROM arm32v7/python:3.9.7-alpine3.14

RUN apk add --no-cache \
    build-base \
    cmake \
    jpeg-dev \
    zlib-dev \
    libjpeg \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    tiff-dev \
    openblas-dev \
    libffi-dev \
    openssl-dev \
    gcc \
    musl-dev \
    python3-dev \
    py3-pip \
    py3-numpy \
    py3-pillow \
    && pip install opencv-python-headless redis \
    && rm -rf /var/cache/apk/*

WORKDIR /app
COPY . .

# Run python server
CMD ["python3", "server.py"]