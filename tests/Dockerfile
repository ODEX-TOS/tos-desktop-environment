FROM f0xedb/tos-base:latest

# install only the desktop environment
RUN pacman -Syu tde --noconfirm

# Mount Tos-desktop-environment to /data
WORKDIR /data

CMD [ "bash", "test-runner.sh" ]
