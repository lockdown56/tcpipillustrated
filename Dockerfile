FROM ubuntu:20.10
COPY sources.list /etc/apt/sources.list

RUN apt-get -y update \
    && apt-get install -y \
       openssh-server iproute2 iputils-arping net-tools tcpdump curl telnet iputils-tracepath traceroute iputils-ping vim
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump
RUN mkdir /run/sshd
ENTRYPOINT /usr/sbin/sshd -D
