# README

Ansible Structure for a mail gateway
Two nodes, DNS balanced.


## What

Install a mail gateway on FreeBSD using ENV VARS.


## Run

Configure Variables in *env_vars.conf* first.

```
source config.sh
```

```
ansible-playbook -s play.yml
```


## Testing Mode

Set variable debug to true in * defaults/main.yml*

```
debug_vars: true
```


## TODO

a lot...


