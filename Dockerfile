FROM maitredede/ubuntu-xenial-qemu
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y expect && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "bash" ]