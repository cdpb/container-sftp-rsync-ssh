#!/bin/bash

export SSHUSER_sshonlyuser="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICksVY/byP0hFo57UQQBoptpcl3FtoPgMaK6Qpxk3Pa+ fos@fos"
export SSHUSER_cbrunert="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICksVY/byP0hFo57UQQBoptpcl3FtoPgMaK6Qpxk3Pa+ fos@fos"
export SSHUSER_cbrunert_sftpdir=/data/test

globalPrefix="SSHUSER"

user_envs=$(env | grep ${globalPrefix}_ | grep -ve sftpdir)
#user_envs=$(env | grep ${globalPrefix}_ | grep $(for config in $configOptions; do echo -ve $config ; done ))

if [[ -z "${user_envs}" ]]; then
  echo "no user provided"
  echo "usage:"
  echo "SSHUSER_<username>=ssh-rsa xyz"
  echo "SSHUSER_<username>_sftpdir=/data"
  exit 1
fi

IFS=$'\n'
for user in ${user_envs}; do
  user_k=$(echo $user | cut -d'=' -f1)
  user_name=$(echo $user_k | cut -d'=' -f1 | sed "s/${globalPrefix}_//g")

  if ! id $user_name; then
    user_key=$(printenv $user_k)
    if echo $user_key | ssh-keygen -lf -; then 
      sftp_dir_key=$(echo ${globalPrefix}_${user_name}_sftpdir)
      sftp_dir=$(printenv $sftp_dir_key)
      if [[ -n $sftp_dir ]]; then
	useradd -m -s /sbin/nologin -G sftponlygrp ${user_name}
	cat <<-EOF > /etc/ssh/sshd_config.d/sftpdir_${user_name}.conf
Match User ${user_name}
  ChrootDirectory $sftp_dir
EOF
        #install -d -D -o root -g root -m 0755  $(dirname $sftp_dir)
        install -d -D -o root -g root -m 0755 $sftp_dir
	#install -d -o ${user_name} -g ${user_name} -m 0750 $sftp_dir
      else
	useradd -m -p '*' -G sshonlygrp ${user_name}
      fi

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
