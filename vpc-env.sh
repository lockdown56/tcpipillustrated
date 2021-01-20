#!/bin/bash

publiceth=$1
imagename=$2

#预配置环境
systemctl stop ufw
systemctl disable ufw

/sbin/iptables -P FORWARD ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p
/sbin/iptables -P FORWARD ACCEPT

#创建图中所有的节点，每个一个容器

echo "create all containers"

docker run --privileged=true --net none --name net1 -d ${imagename}
docker run --privileged=true --net none --name proxy_node -d ${imagename}
docker run --privileged=true --net none --name net2 -d ${imagename}
docker run --privileged=true --net none --name net3 -d ${imagename}

#创建两个网桥，代表两个二层网络
echo "create bridges"

ovs-vsctl del-br net1
ovs-vsctl del-br net2
ovs-vsctl del-br net3

ovs-vsctl add-br net1
ip link set net1 up
ovs-vsctl add-br net2
ip link set net2 up
ovs-vsctl add-br net3
ip link set net3 up

#brctl addbr net1
#brctl addbr net2

#将所有的节点连接到两个网络
echo "connect all containers to bridges"

chmod +x ./pipework

./pipework net1 net1 192.168.1.100/24
./pipework net1 proxy_node 192.168.1.101/24

./pipework net2 net2 192.168.2.100/24
./pipework net2 proxy_node 192.168.2.101/24 eth2

./pipework net3 net3 192.168.2.100/24
./pipework net3 proxy_node 192.168.2.101/24 eth3
