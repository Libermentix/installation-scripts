#!/bin/bash
echo "granting sudo access rights to git and sites users for deployment process"
cat > /etc/sudoers.d/grant_git_access_to_deploy << EOF
git ALL=(root) NOPASSWD: /home/sites/bin/restart-python-app.sh, (sites) NOPASSWD: /home/sites/bin/deploy-python-app.sh
sites ALL=(root) NOPASSWD: /home/sites/bin/restart-python-app.sh
EOF
