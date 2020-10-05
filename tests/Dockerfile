FROM f0xedb/tos-base:latest

# install only the desktop environment
RUN pacman -Syu awesome-tos --noconfirm

# Mount Tos-desktop-environmnet to /data
WORKDIR /data

CMD [ "bash", "test-runner.sh" ]
