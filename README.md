# AuthKeys docker-ansible

## Description

This image execute `ansible` and let you pass your ansible's arguments directly to the container.


## Usage

You need to mount your ansible folder in `/ansible`

Supposing you execute the container within your ansible folder you can run:

```
docker run -it --rm \
  -v $PWD:/ansible \
  authkeys/docker-ansible --ask-become-pass --ask-pass playbook.yml
```

## Environments

You can pass some envs to the container:

* `SSH_KEY` name of the SSH key you want to use.
  No default.
  It must exists in /root/.ssh
* `PYTHON_REQUIREMENTS` path to a file that contains the python modules needed by ansible.
  Default value `requirements-pip.txt` .
  If file exists, the command `pip3 install -r <file>` is executed
* `ANSIBLE_REQUIREMENTS` path to a file that contains ansible modules.
  Default value `requirements.yml` .
  If file exists, the command `ansible-galaxy install --force -r <file>` is executed
* `ANSIBLE_PRE_PLAYBOOK` path to a playbook file.
  No Default.
  If file exists, the command `ansible-playbook ${ANSIBLE_PRE_PLAYBOOK_OPTS} <file>` is executed.
  `ANSIBLE_PRE_PLAYBOOK_OPTS` contains optional arguments passed to pre-playbook execution.


## Examples

### With askpass

```
docker run -it --rm \
  -v $PWD:/ansible \
  authkeys/docker-ansible --ask-pass playbook.yml
```


### Using your SSH key

```
docker run -it --rm \
  -e SSH_KEY=id_ed25519 \
  -v $HOME/.ssh:/root/.ssh \
  -v $PWD:/ansible \
  authkeys/docker-ansible playbook.yml
```

If your SSH key is protected with a passphrase, you will be prompted to enter it

### With PYTHON_REQUIREMENTS

```
docker run -it --rm \
  -e SSH_KEY=id_ed25519 \
  -e PYTHON_REQUIREMENTS=/python/requirements.txt \
  -v requirements.txt:/python/requirements.txt \
  -v $HOME/.ssh:/root/.ssh \
  -v $PWD:/ansible \
  authkeys/docker-ansible playbook.yml
```

### With ANSIBLE_REQUIREMENTS

```
docker run -it --rm \
  -e SSH_KEY=id_ed25519 \
  -e ANSIBLE_REQUIREMENTS=/extra/requirements.yaml \
  -v requirements.yaml:/extra/requirements.yaml \
  -v $HOME/.ssh:/root/.ssh \
  -v $PWD:/ansible \
  authkeys/docker-ansible playbook.yml
```

### With ANSIBLE_PRE_PLAYBOOK

We need to run a playbook to add remote hosts' public keys to known_hosts before executing our playbook

```
docker run -it --rm \
  -e ANSIBLE_PRE_PLAYBOOK=ssh_keyscan.yml \
  -e ANSIBLE_PRE_PLAYBOOK_OPTS=--forks=1 \
  -e SSH_KEY=id_ed25519 \
  -v $HOME/.ssh/id_ed25519:/root/.ssh/id_ed25519:ro \
  -v $PWD:/ansible \
  authkeys/docker-ansible playbook.yml
```
