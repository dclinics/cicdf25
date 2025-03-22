#cloud-config
users:
%{ for user in users ~}
  - name: ${lower(replace(user, " ", "_"))}
    gecos: "${user}"
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    passwd: ${passwd}
    lock_passwd: false
    expire: false
%{ endfor ~}

chpasswd:
  expire: true

# Set password expiration policy for 30 days
runcmd:
  - for user in $(awk -F':' '{ print $1}' /etc/passwd); do chage -M 30 $user; done
