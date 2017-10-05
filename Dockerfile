FROM maitredede/ubuntu-xenial-qemu
RUN apt-get install expect
ENTRYPOINT [ "bash" ]