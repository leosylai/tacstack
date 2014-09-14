# Centos 6.5
FROM jumanjiman/puppetagent

# Commenting out the following until its needed
# ADD src /tmp/src
# RUN echo "NETWORKING=yes" > /etc/sysconfig/network
# RUN puppet apply --modulepath=/tmp /tmp/src/test/init.pp


# install packages
RUN yum -y install \
    httpd vim-enhanced bash-completion unzip \
    mysql mysql-server \
    php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml \
    phpmyadmin \
    openssh-server openssh-clients passwd \
    python python-pip python-nose python-pep8 \
    gcc \
    mysql-devel python-devel \
    ; yum clean all
    
RUN yum -y groupinstall 'Development tools'
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

RUN yum -y install \
    libxslt-devel libxslt libxslt-python \
    libxml2-devel libxml2 libxml2-python \
    python-lxml \
    ; yum clean all

# install supervisord
RUN pip install "pip>=1.4,<1.5" --upgrade
RUN pip install supervisor MySQL-python robotframework lxml

# Configure sshd.
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && echo 'root:changeme' | chpasswd

# Ports: 22=ssh, 80=http, 3306=mysql, 42448=MAP
EXPOSE 22 80 3306 42448

ADD /src/files/phpMyAdmin.conf /etc/httpd/conf.d/
ADD /src/files/my.cnf /etc/my.cnf
RUN service mysqld start
RUN mysql_install_db

RUN /oval/remediate-oscap.sh
RUN /oval/vulnerability-scan.sh

ADD /src/files/supervisord.conf /etc/
CMD ["supervisord", "-n"]