FROM ubuntu:22.04 AS base
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openssh-client \
    sshpass \
    python3-pip \
    git-core \
    vim \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /requirements/
RUN pip3 install --no-cache-dir -r /requirements/requirements.txt

WORKDIR /ansible
COPY docker-entrypoint.sh /usr/bin/
COPY ansible-ssh /usr/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "--help" ]

FROM base AS terraform
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
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

# Metadata
LABEL name="authkeys/docker-ansible" \
        description="ansible in a container" \
        org.opencontainers.image.vendor="AuthKeys" \
        org.opencontainers.image.source="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.title="docker-ansible" \
        org.opencontainers.image.description="ansible in a container" \
        org.opencontainers.image.documentation="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.licenses='Apache-2.0'
