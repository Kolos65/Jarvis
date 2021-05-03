 
# Base Image
FROM kolos65/python-opencv-dlib:armv7

# ffmpeg
RUN apk add ffmpeg

# Copy source
COPY . ./jarvis
WORKDIR ./jarvis

# Required to build crypto
RUN apk add --update rust
RUN apk add \
    musl-dev \
    libffi-dev \
    openssl-dev \
    cargo

# Python Deps
RUN pip3 install -r requirements.txt

# Start server
CMD gunicorn \
    --threads 5 \
    --timeout 300 \
    --bind 0.0.0.0:3000 \
    wsgi:app












