FROM gitpod/workspace-base

ARG MAMBAFORGE_VERSION="4.10.0-0"
ARG CONDA_ENV=nfl-dev

ENV CONDA_DIR=/home/gitpod/mambaforge \
    SHELL=/bin/bash
ENV PATH=${CONDA_DIR}/bin:$PATH

USER root

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    ca-certificates \
    dirmngr \
    dvisvgm \
    gnupg \
    gpg-agent \
    texlive-latex-extra \
    vim && \
    # this needs to be done after installing dirmngr
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-add-repository https://cli.github.com/packages && \
    apt-get install -yq --no-install-recommends \
    gh && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/cache/apt/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /tmp/*

SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

RUN wget -q -O mambaforge.sh \
    "https://github.com/conda-forge/miniforge/releases/download/$MAMBAFORGE_VERSION/Mambaforge-$MAMBAFORGE_VERSION-Linux-x86_64.sh" && \
    bash mambaforge.sh -p ${CONDA_DIR} -b && \
    rm mambaforge.sh

COPY ./tools/gitpod/workspace_config /usr/local/bin/workspace_config

RUN chmod a+rx /usr/local/bin/workspace_config && \
    workspace_config
    
RUN mamba env create -f /tmp/environment.yml && \
    conda activate ${CONDA_ENV} && \
    mamba install ccache -y && \
    conda clean --all -f -y && \
    rm -rf /tmp/*

USER gitpod
