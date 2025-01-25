#!/bin/sh

globalPrefix="SSHUSER"

user_envs=$(env | grep ${globalPrefix}_)

if [[ -z "${user_envs}" ]]; then
  echo "no user provided"
  echo "usage:"
  echo "SSHUSER_<username>=ssh-rsa xyz"
  exit 1
fi

IFS=$'\n'
for user in ${user_envs}; do
  user_k=$(echo $user | cut -d'=' -f1)
  user_name=$(echo $user_k | cut -d'=' -f1 | sed "s/${globalPrefix}_//g")

  if ! id $user_name; then
    user_key=$(printenv $user_k)
    if echo $user_key | ssh-keygen -lf -; then 
      useradd -m -p '*' -G sshonlygrp ${user_name}
      install -d -o ${user_name} -g ${user_name} -m 0700 /home/${user_name}/.ssh
      echo "${user_key}" | install -o ${user_name} -g ${user_name} -m 0600 /dev/stdin /home/${user_name}/.ssh/authorized_keys

      echo "creating user $(id $user_name)"
      echo ""
    else
      echo "ssh key for user $user_name is invalid"
    fi
  fi
done

if [[ ! -f /etc/ssh/ssh_host_rsa_key.pub ]]; then
  ssh-keygen -A
fi

find /etc/ssh -name *.pub -exec ssh-keygen -lf {} \;

exec $@
