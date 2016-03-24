FROM openmicroscopy/omero-ssh-systemd

MAINTAINER OME

ENV JENKINS_SWARM_VERSION 2.0
ENV LANG en_US.UTF-8

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers


RUN yum -y localinstall http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm
RUN yum -y install nginx && yum clean all
RUN mv /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.disabled

VOLUME ["/etc/nginx/conf.d", "/var/log/nginx"]

WORKDIR /etc/nginx

RUN systemctl enable nginx

EXPOSE 80 443

RUN yum install yum -y install java-1.8.0-openjdk && yum clean all

RUN yum install -y http://download-aws.ej-technologies.com/exe4j/exe4j_linux_5_0_1.rpm && yum clean all

USER omero
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

USER root

ADD ./jenkins-slave.sh /tmp/jenkins-slave.sh
RUN chmod +x /tmp/jenkins-slave.sh
ADD ./jenkins.service /etc/systemd/system/jenkins.service
RUN systemctl enable jenkins.service


#ENTRYPOINT ["/tmp/jenkins-slave.sh"]
