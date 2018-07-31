#!/bin/bash -x

# Read configuration files
ARTIFACTS_VERSION=$(cat /opt/config/artifacts_version.txt)
DNS_IP_ADDR=$(cat /opt/config/dns_ip_addr.txt)
CLOUD_ENV=$(cat /opt/config/cloud_env.txt)
MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)
HTTP_PROXY=$(cat /opt/config/http_proxy.txt)
HTTPS_PROXY=$(cat /opt/config/https_proxy.txt)

if [ $HTTP_PROXY != "no_proxy" ]
then
    export http_proxy=$HTTP_PROXY
    export https_proxy=$HTTPS_PROXY
fi

# Short-term fix to get around MSO to SO name change
cp /opt/config/so_ip_addr.txt /opt/config/mso_ip_addr.txt

# Add host name to /etc/host to avoid warnings in openstack images
if [[ $CLOUD_ENV != "rackspace" ]]
then
	echo 127.0.0.1 $(hostname) >> /etc/hosts

	# Allow remote login as root
	mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bk
	cp /home/ubuntu/.ssh/authorized_keys /root/.ssh
fi

# Set private IP in /etc/network/interfaces manually in the presence of public interface
# Some VM images don't add the private interface automatically, we have to do it during the component installation
if [[ $CLOUD_ENV == "openstack_nofloat" ]]
then
	LOCAL_IP=$(cat /opt/config/local_ip_addr.txt)
	CIDR=$(cat /opt/config/oam_network_cidr.txt)
	BITMASK=$(echo $CIDR | cut -d"/" -f2)

	# Compute the netmask based on the network cidr
	if [[ $BITMASK == "8" ]]
	then
		NETMASK=255.0.0.0
	elif [[ $BITMASK == "16" ]]
	then
		NETMASK=255.255.0.0
	elif [[ $BITMASK == "24" ]]
	then
		NETMASK=255.255.255.0
	fi

	echo "auto eth1" >> /etc/network/interfaces
	echo "iface eth1 inet static" >> /etc/network/interfaces
	echo "    address $LOCAL_IP" >> /etc/network/interfaces
	echo "    netmask $NETMASK" >> /etc/network/interfaces
	echo "    mtu $MTU" >> /etc/network/interfaces
	ifup eth1
fi

apt-get update
apt-get install -y apt-transport-https ca-certificates wget git ntp ntpdate make

# Download scripts from Nexus
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot_vm_init.sh > /opt/robot_vm_init.sh
chmod +x /opt/robot_vm_init.sh
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot_serv.sh > /opt/robot_serv.sh
chmod +x /opt/robot_serv.sh
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip imagetest.sh > /opt/imagetest.sh
chmod +x /opt/imagetest.sh

mkdir -p /opt/eteshare/config
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot/integration_preload_parameters.py > /opt/eteshare/config/integration_preload_parameters.py
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot/integration_robot_properties.py > /opt/eteshare/config/integration_robot_properties.py
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot/vm_config2robot.sh > /opt/eteshare/config/vm_config2robot.sh
chmod +x /opt/eteshare/config/vm_config2robot.sh
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot/ete.sh > /opt/ete.sh
chmod +x /opt/ete.sh
unzip -p -j /opt/boot-$ARTIFACTS_VERSION.zip robot/demo.sh > /opt/demo.sh
chmod +x /opt/demo.sh

mkdir -p /opt/eteshare/logs

cp /opt/robot_serv.sh /etc/init.d
update-rc.d robot_serv.sh defaults

# Download and install docker-engine
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y --allow-unauthenticated docker-engine

# Set the MTU size of docker containers to the minimum MTU size supported by vNICs. OpenStack deployments may need to know the external DNS IP
DNS_FLAG=""
if [ -s /opt/config/dns_ip_addr.txt ]
then
	DNS_FLAG=$DNS_FLAG"--dns $(cat /opt/config/dns_ip_addr.txt) "
fi
if [ -s /opt/config/external_dns.txt ]
then
	DNS_FLAG=$DNS_FLAG"--dns $(cat /opt/config/external_dns.txt) "
fi
echo "DOCKER_OPTS=\"$DNS_FLAG--mtu=$MTU\"" >> /etc/default/docker

cp /lib/systemd/system/docker.service /etc/systemd/system
sed -i "/ExecStart/s/$/ --mtu=$MTU/g" /etc/systemd/system/docker.service
if [ $HTTP_PROXY != "no_proxy" ]
then
cd /opt
./imagetest.sh
fi
service docker restart

# DNS IP address configuration
echo "nameserver "$DNS_IP_ADDR >> /etc/resolvconf/resolv.conf.d/head
resolvconf -u


# Rename network interface in openstack Ubuntu 16.04 images. Then, reboot the VM to pick up changes
if [[ $CLOUD_ENV != "rackspace" ]]
then
	sed -i "s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/g" /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	sed -i "s/ens[0-9]*/eth0/g" /etc/network/interfaces.d/*.cfg
	sed -i "s/ens[0-9]*/eth0/g" /etc/udev/rules.d/70-persistent-net.rules
	echo 'network: {config: disabled}' >> /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
	echo "APT::Periodic::Unattended-Upgrade \"0\";" >> /etc/apt/apt.conf.d/10periodic
	reboot
fi

# Run docker containers. For openstack Ubuntu 16.04 images this will run as a service after the VM has restarted
./robot_vm_init.sh
