FROM ubuntu:24.04 AS base
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git-core \
    jq \
    less \
    openssh-client \
    python3-venv \
    sshpass \
    vim \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/bin/
COPY ansible-ssh /usr/bin/

ARG ANSIBLE_HOME=/home/ansible

RUN useradd --create-home --home-dir ${ANSIBLE_HOME} ansible
USER ansible

COPY requirements.txt ${ANSIBLE_HOME}
ENV VIRTUAL_ENV=${ANSIBLE_HOME}/venv
RUN python3 -m venv ${VIRTUAL_ENV}

# same as activating the virtual env
ENV PATH=${VIRTUAL_ENV}/bin:$PATH
RUN pip install --no-cache-dir -r ${ANSIBLE_HOME}/requirements.txt

WORKDIR /ansible

# smoke tests
RUN ansible --version && ansible-lint --version

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "--help" ]

FROM base AS terraform
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    software-properties-common \
    wget \
    && wget --quiet -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor >/usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >/etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y --no-install-recommends terraform \
    && rm -rf /var/lib/apt/lists/*
USER ansible

# smoke tests
RUN terraform --version

# Metadata
LABEL name="authkeys/docker-ansible" \
        description="ansible in a container" \
        org.opencontainers.image.vendor="AuthKeys" \
        org.opencontainers.image.source="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.title="docker-ansible" \
        org.opencontainers.image.description="ansible in a container" \
        org.opencontainers.image.documentation="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.licenses='Apache-2.0'
