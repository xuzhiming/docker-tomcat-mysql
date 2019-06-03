FROM openjdk:8-jdk
MAINTAINER Manuel de la Peña <manuel.delapenya@liferay.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TOMCAT_MAJOR_VERSION=7
ENV TOMCAT_VERSION=7.0.94
ENV TOMCAT_HOME=/opt/apache-tomcat-$TOMCAT_VERSION
ENV ES_VERSION=6.6.2
ENV ES_HOME=/opt/elasticsearch-$ES_VERSION

# debain source use mirror 163
# RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
#     echo "deb http://mirrors.163.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
#     echo "deb http://mirrors.163.com/debian/ proposed-updates main non-free contrib" >>/etc/apt/sources.list && \
#     echo "deb-src http://mirrors.163.com/debian/ jessie main non-free contrib" >>/etc/apt/sources.list && \
#     echo "deb-src http://mirrors.163.com/debian/ proposed-updates main non-free contrib" >>/etc/apt/sources.list

# Prepare the installation of mysql-server and tomcat 7
RUN apt-get update && apt-get install -y lsb-release && \
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.4-1_all.deb && \
  dpkg -i mysql-apt-config_0.8.4-1_all.deb && rm -f mysql-apt-config_0.8.4-1_all.deb && \
  mkdir -p $TOMCAT_HOME && cd /opt && \
  wget http://mirrors.standaloneinstaller.com/apache/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
  tar -xvf apache-tomcat-$TOMCAT_VERSION.tar.gz && rm -f apache-tomcat-$TOMCAT_VERSION.tar.gz

# Install Elasticsearch
RUN mkdir -p $ES_HOME && cd /opt && \ 
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz && \
    # https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz 
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-$ES_VERSION.tar.gz.sha512 && \
    tar -xzf elasticsearch-$ES_VERSION.tar.gz && rm -f elasticsearch-$ES_VERSION.tar.gz


# Install packages
RUN apt-get update && \
  apt-get --force-yes -y install mysql-server pwgen supervisor && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add image configuration and scripts
ADD start-tomcat.sh /start-tomcat.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD start-es.sh /start-es.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 644 /etc/mysql/conf.d/my.cnf
ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

ADD elasticsearch.yml $ES_HOME/config/elasticsearch.yml
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
# ADD supervisord-elasticsearch.conf /etc/supervisor/conf.d/supervisord-es.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD mysql-setup.sh /mysql-setup.sh
RUN chmod 755 /*.sh

WORKDIR $TOMCAT_HOME

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 8080 3306 9200 9300

ENTRYPOINT ["/run.sh"]
