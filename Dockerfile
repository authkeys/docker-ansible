FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y curl openssh-client sshpass python3 python3-pip git-core vim jq yamllint && \
    rm -rf /var/lib/apt/lists/*
COPY requirements.txt /requirements/
RUN pip3 install --no-cache-dir -r /requirements/requirements.txt
WORKDIR /ansible
COPY docker-entrypoint.sh /usr/bin/
COPY ansible-ssh /usr/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "--help" ]


# Metadata
LABEL name="authkeys/docker-ansible" \
        description="ansible in a container" \
        org.opencontainers.image.vendor="AuthKeys" \
        org.opencontainers.image.source="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.title="docker-ansible" \
        org.opencontainers.image.description="ansible in a container" \
        org.opencontainers.image.version="0.3.0" \
        org.opencontainers.image.documentation="https://github.com/authkeys/docker-ansible" \
        org.opencontainers.image.licenses='Apache-2.0'
