FROM mambaorg/micromamba
USER root
RUN apt update \
    && apt install -y curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L $(curl https://quarto.org/docs/download/_prerelease.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb") -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb
USER $MAMBA_USER
