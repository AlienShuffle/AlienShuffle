On the Windows 11 Box, assuming a currently supported version of WSL is installed, you need to do the following:

create a file /etc/wsl.conf with the following content:
[boot]
systemd=true
command="service cron start"

also add the following lines to the end of the /etc/sudoers file (not sure which is the magic one, but likely the first:
%sudo ALL=NOPASSWD: /usr/sbin/service cron start
%sudo ALL=NOPASSWD: /etc/init.d/cron start
%sudo ALL=NOPASSWD: /usr/local/bin/cronstart.sh

create a one line cronstart.sh script for end-user help if desired:
sudo echo '/usr/sbin/service cron start' > /usr/local/bin/cronstart.sh ; chmod +x /usr/local/bin/cronstart.sh
