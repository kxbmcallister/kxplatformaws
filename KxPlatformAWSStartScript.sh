#!/bin/bash
# Read in PKG_NAME
PKG_NAME=$1

# Constants
PKG_TGZ_NAME=${PKG_NAME}-BETA.tgz
HOSTNAME=<FQDN HOSTNAME>
S3_BKT=<S3 bucket name>

# Update /etc/hosts to apply appropriate FQDN information
echo -e "127.0.1.1\t$HOSTNAME" >> /etc/hosts
hostname $HOSTNAME
echo $HOSTNAME > /etc/hostname

# Install Java
yum install java-1.8.0-openjdk.x86_64 -y

# Download Platform Instance from nexus
mkdir packages
cd packages
aws s3 cp s3://${S3_BKT}/bundles/$PKG_TGZ_NAME .

# Run install
tar -xvf $PKG_TGZ_NAME
cd $PKG_NAME/scripts

# Copy licenses in
aws s3 cp s3://${S3_BKT}/lics/.delta.lic .
aws s3 cp s3://${S3_BKT}/lics/k4.lic .
aws s3 cp s3://${S3_BKT}/kxplatformnoprompt.install.config .
./installDeltaXML.sh -p kxplatformnoprompt.install.config

cd /home/ec2-user/kxinstall
chown -R ec2-user .
chgrp -R ec2-user .

# Start it
cd delta-bin/bin/
sudo -u ec2-user ./startDeltaControl.sh
sudo -u ec2-user ./startDeltaControlDaemon.sh --java.memory.xms=256 --java.memory.xmx=256 --delta.daemon.sysmon=false
sudo -u ec2-user ./startAppServer.sh

## TODO Create Hook to post install packages (from git or otherwise)
## TODO Create secrets file to read in password and username for nexus
## TODO Make sure one arg is provided and make sure the bundle exists on s3
## TODO Add mode to start without install
