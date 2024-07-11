# Build requires the root as the context as it COPYs from a shared library.
FROM quay.io/jupyter/scipy-notebook:python-3.11.8 as base
WORKDIR /app
LABEL maintainer="Kahihikolo_Kaimi@bah.com"

USER jovyan

# Install all slow-to-install dependencies
COPY ./requirements/large_requirements.txt ./requirements/large_requirements.txt
RUN --mount=type=cache,target=/home/jovyan/.cache/pip,sharing=locked,uid=1000,gid=100 \
    --mount=type=cache,target=/opt/conda/pkgs,sharing=locked,uid=1000,gid=100 \
    pip install -r ./requirements/large_requirements.txt

# Install all fast pypi dependencies
COPY ./requirements/requirements.txt ./requirements/requirements.txt
RUN --mount=type=cache,target=/home/jovyan/.cache/pip,sharing=locked,uid=1000,gid=100 \
    --mount=type=cache,target=/opt/conda/pkgs,sharing=locked,uid=1000,gid=100 \
    pip install -r ./requirements/requirements.txt

ENV NOTEBOOK_PATH=/app/notebooks

FROM base as code-server

USER root

RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" \
        --output /tmp/vscode-cli.tar.gz && \
    tar -xf /tmp/vscode-cli.tar.gz -C /usr/bin && \
    rm /tmp/vscode-cli.tar.gz

CMD [ "code", "tunnel", "--accept-server-license-terms" ]
