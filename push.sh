#\!/usr/bin/env bash
# Usage: sudo /etc/nixos/push.sh "commit message"
cd /etc/nixos
git add -A
if [ -n "$1" ]; then
  msg="$1"
else
  msg="Update NixOS configuration"
fi
git commit -m "$msg" || { echo "Nothing to commit"; exit 0; }
sudo -u yg git push
