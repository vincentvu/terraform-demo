#!/bin/bash

# config DNS servers
cat > /etc/resolv.conf <<EOF 
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# update repo
apt-get update

# instlall curl, net-tools, wget, git
apt-get install -y curl net-tools wget git tree python-git vim

# Instlall saltstack
curl -o saltstack_bootstrap.sh -L https://bootstrap.saltstack.com
sh ./saltstack_bootstrap.sh stable 2016.3

# Configure role
cat > /etc/salt/grains  <<EOF
roles:
  - wordpress
EOF

# Install formulas
SRV_DIR=/srv

# Configure minion
cat > /etc/salt/minion <<EOF
failhard: False
file_client: local
local: true
state_verbose: True
state_output: mixed
log_level: debug
EOF

# Configure file_roots
FORMULAS_DIR=${SRV_DIR}/demo-saltstack-formulas
cd ${SRV_DIR}
git clone https://github.com/vincentvu/demo-saltstack-formulas.git
cd ${FORMULAS_DIR}
git pull
git submodule sync
git submodule update --init

echo "file_roots:" > /etc/salt/minion.d/file_roots.conf
echo "  base:" >> /etc/salt/minion.d/file_roots.conf
echo "    - ${FORMULAS_DIR}" >> /etc/salt/minion.d/file_roots.conf

for f in `ls ${FORMULAS_DIR} | grep -v top.sls`
do
	echo "add formula ${FORMULAS_DIR}/$f into saltstack file_roots"
	echo "    - ${FORMULAS_DIR}/$f" >> /etc/salt/minion.d/file_roots.conf
done

# Configure pillar
PILLARS_DIR=${SRV_DIR}/demo-saltstack-pillars
cd ${SRV_DIR}
git clone https://github.com/vincentvu/demo-saltstack-pillars.git
echo "pillar_roots:" > /etc/salt/minion.d/pillar_roots.conf
echo "  base:" >> /etc/salt/minion.d/pillar_roots.conf
echo "    - ${PILLARS_DIR}" >> /etc/salt/minion.d/pillar_roots.conf

# Restart saltstack
systemctl restart salt-minion

# Configure server
salt-call state.apply

# Configure pillar_roots
#pillar_roots:
#  base:
#    - /srv/pillar
# gitfs_provider: pygit2
# gitfs_remotes:
#   - https://github.com/vincentvu/demo-saltstack-pillars.git
# 
# pip install pythongit
# 
# gitfs_provider: gitpython
# ext_pillar:
#   - git: master https://github.com/vincentvu/demo-saltstack-pillars.git
# 
# # Configure role
# cat /etc/salt/grains 
#  roles:
#    - wordpress