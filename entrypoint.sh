#!/bin/sh

touch ${SSH_KEY_FILE:=/id_rsa}
chmod 0400 ${SSH_KEY_FILE:=/id_rsa}

STRICT_HOSTS_KEY_CHECKING=no
KNOWN_HOSTS=${SSH_KNOWN_HOSTS:=/known_hosts}
if [ -f "${KNOWN_HOSTS}" ]; then
    chmod 0400 ${KNOWN_HOSTS}
    KNOWN_HOSTS_ARG="-o UserKnownHostsFile=${KNOWN_HOSTS}"
    STRICT_HOSTS_KEY_CHECKING=yes
fi

# Pick a random port above 32768
DEFAULT_PORT=$RANDOM
let "DEFAULT_PORT += 32768"
echo [INFO] Tunneling ${SSH_HOSTUSER:=root}@${SSH_HOSTNAME:=localhost}:${SSH_TUNNEL_REMOTE:=${DEFAULT_PORT}} to ${SSH_TUNNEL_HOST=localhost}:${SSH_TUNNEL_LOCAL:=22}

SSH_TUNNEL_BIND="${SSH_TUNNEL_BIND:-}"
ssh_tunnel_bind_opt=""
if [ -n "$SSH_TUNNEL_BIND" ]
then ssh_tunnel_bind_opt="${SSH_TUNNEL_BIND}:"
fi

echo autossh \
 -M 0 \
 -N \
 -o StrictHostKeyChecking=${STRICT_HOSTS_KEY_CHECKING} ${KNOWN_HOSTS_ARG:=} \
 -o ServerAliveInterval=5 \
 -o ServerAliveCountMax=1 \
 -t -t \
 -i ${SSH_KEY_FILE:=/id_rsa} \
 ${SSH_MODE:=-R} ${ssh_tunnel_bind_opt}${SSH_TUNNEL_REMOTE}:${SSH_TUNNEL_HOST}:${SSH_TUNNEL_LOCAL} \
 -p ${SSH_HOSTPORT:=22} \
 ${SSH_HOSTUSER}@${SSH_HOSTNAME}

AUTOSSH_PIDFILE=/autossh.pid \
AUTOSSH_POLL=10 \
AUTOSSH_LOGLEVEL=0 \
AUTOSSH_LOGFILE=/dev/stdout \
autossh \
 -M 0 \
 -N \
 -o StrictHostKeyChecking=${STRICT_HOSTS_KEY_CHECKING} ${KNOWN_HOSTS_ARG:=}  \
 -o ServerAliveInterval=5 \
 -o ServerAliveCountMax=1 \
 -t -t \
 -i ${SSH_KEY_FILE:=/id_rsa} \
 ${SSH_MODE:=-R} ${ssh_tunnel_bind_opt}${SSH_TUNNEL_REMOTE}:${SSH_TUNNEL_HOST}:${SSH_TUNNEL_LOCAL} \
 -p ${SSH_HOSTPORT:=22} \
 ${SSH_HOSTUSER}@${SSH_HOSTNAME}
