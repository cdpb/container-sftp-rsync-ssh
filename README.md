# SSH Container with rsync

## Usage
```
docker run --rm -d -e SSHUSER_test="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICksVY/byP0hFo57UQQBoptpcl4FtoPgMaK6Qpxk3Pa+" -p 9022:22 docker.io/cdpb/container-sftp-rsync-ssh

```

SSHUSER_<username>="ssh pub key"

- checks if ssh key is valid
- create user
- create server pub keys
- starts sshd

SSHUSER_ can be used multiple times
