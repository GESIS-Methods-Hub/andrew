FROM docker-private-snapshots.gesis.intra/gesis/methods-hub/quarto:latest
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml \
    && micromamba clean --all --yes \
    && rm -rf /opt/conda/conda-meta /tmp/env.yaml