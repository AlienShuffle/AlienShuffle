Configure WSL on Win11 to automically start cron
---
This provides guidance on how to start cron automatically upon boot or a WSL instance. It has limitations
- It does not actually start WSL upon boot of the Windows instance, you need to launch a WSL process (e.g., wsl.exe) to get the Linux instance running.
- All attempts at getting it to run and stay running automatically have failed, just need do stuff to ensure WSL is manually started every time Windows host reboots :-(

On the Windows 11 Box, assuming a currently supported version of WSL is installed, you need to do the following:

- Create a file /etc/wsl.conf with the following content:
```
[boot]
systemd=true
command="service cron start"
```

- Add the following lines to the end of the /etc/sudoers file (not sure which is the magic one, but likely the first:
```
%sudo ALL=NOPASSWD: /usr/sbin/service cron start
%sudo ALL=NOPASSWD: /etc/init.d/cron start
%sudo ALL=NOPASSWD: /usr/local/bin/cronstart.sh
```

- Create a one line cronstart.sh script for end-user help if desired:
```bash
sudo echo '/usr/sbin/service cron start' > /usr/local/bin/cronstart.sh ; chmod +x /usr/local/bin/cronstart.sh
```
