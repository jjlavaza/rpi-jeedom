FROM  balenalib/armv7hf-debian

# Enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
#RUN [ "cross-build-start" ]

ENV SHELL_ROOT_PASSWORD Jeedom123

# JR
# RUN apt-get clean && apt-get update && apt upgrade && apt-get install --no-install-recommends -y wget openssh-server supervisor mysql-client
RUN apt-get clean && apt-get update && apt upgrade && apt-get install --no-install-recommends -y wget openssh-server supervisor apt-utils


RUN echo "root:${SHELL_ROOT_PASSWORD}" | chpasswd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN mkdir -p /var/run/sshd /var/log/supervisor
WORKDIR /etc
RUN rm /etc/motd && wget -q https://raw.githubusercontent.com/jeedom/core/master/install/motd

WORKDIR /etc/supervisor/conf.d
RUN wget -q https://raw.githubusercontent.com/jeedom/core/master/install/OS_specific/Docker/supervisord.conf

WORKDIR /root
RUN rm -f /root/.bashrc && wget -O .bashrc -q https://raw.githubusercontent.com/jeedom/core/master/install/bashrc

RUN wget -O install_docker.sh -q https://raw.githubusercontent.com/jeedom/core/master/install/install.sh && chmod +x /root/install_docker.sh
RUN /root/install_docker.sh -s 2;exit 0
RUN /root/install_docker.sh -s 4;exit 0
RUN /root/install_docker.sh -s 5;exit 0
RUN /root/install_docker.sh -s 7;exit 0
RUN /root/install_docker.sh -s 10;exit 0

RUN wget -q https://raw.githubusercontent.com/jeedom/core/master/install/OS_specific/Docker/init.sh && chmod +x /root/init.sh

#Ajout JR à partir du DockerFile de codafog
RUN apt update && apt upgrade && apt install mosquitto mosquitto-clients make php-pear libmosquitto-dev php-dev
RUN pecl install Mosquitto-alpha && echo "extension=mosquitto.so" >> /etc/php/7.3/cli/php.ini && echo "extension=mosquitto.so" >>  /etc/php/7.3/apache2/php.ini

# pour essayer de charger la conf automatique
RUN dpkg --configure -a

CMD ["/root/init.sh"]

# stop processing ARM emulation (comment out next line if built on Raspberry)
#RUN [ "cross-build-end" ]
