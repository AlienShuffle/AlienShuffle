#!/bin/bash
#
# this fixes code . not working.
#
echo ':WSLInterop:M::MZ::/init:PF' | sudo tee /usr/lib/binfmt.d/WSLInterop.conf
sudo systemctl restart systemd-binfmt
