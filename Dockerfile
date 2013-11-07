# Tutorial
#
# VERSION 	1.0


FROM ubuntu
MAINTAINER Fred Hsu <fredlhsu@gmail.com>

# make sure package repo is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# install tools
RUN apt-get install -y supervisor openssh-server

RUN mkdir -p /var/run/sshd

# install quagga
RUN apt-get install -y quagga

# enable daemons
RUN sed -i 's/=no/=yes/g' /etc/quagga/daemons

# turn on ip forwarding
RUN echo "1" > /proc/sys/net/ipv4/ip_forward

# copy the default configs for the routing daemons
# TODO: replace this with using ADD for local files
RUN cp /usr/share/doc/quagga/examples/*.sample /etc/quagga/
RUN echo "for curFile in /etc/quagga/*.sample; do mv \"\$curFile\" \"\${curFile:0:-7}\"; done" | bash
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# this would be preferred, but doesn't work b/c of privilege
#RUN /etc/init.d/quagga start

# using supervisor to launch ssh and the individual routing daemons
ENTRYPOINT ["/usr/bin/supervisord"]

# expose bgp port
EXPOSE 179

# expose quagga mgmt ports
EXPOSE 2601 2602 2603 2604 2605 2606

# expose ssh
EXPOSE 22
