From ubuntu:15.04
MAINTAINER Chris Wininger <cwininger@airspringsoftware.com>

#install software
RUN apt-get update
RUN apt-get -y install vim curl tmux
RUN echo 'slapd/root_password password password' | debconf-set-selections && \
	echo 'slapd/root_password_again password password' | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

# add our default configs
ADD ./docker-source/initialization /ldap-initialization

RUN service slapd start ;\
	echo 'run back.ldif' &&\
	ldapadd -Y EXTERNAL -H ldapi:/// -f /ldap-initialization/back.ldif &&\
	echo 'create new attributes' &&\
	ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /ldap-initialization/createAttributes.ldif &&\
	echo 'run createOrgUnits.ldif' &&\
	ldapadd -x -D cn=admin,dc=airspring,dc=com -w xxx -c -f /ldap-initialization/createOrgUnits.ldif &&\
	echo 'run createTestUsers.ldif' &&\
	ldapadd -x -D cn=admin,dc=airspring,dc=com -w xxx -c -f /ldap-initialization/createTestUsers.ldif &&\
	echo 'run createUserMembership.ldif' &&\
	ldapadd -x -D cn=admin,dc=airspring,dc=com -w xxx -c -f /ldap-initialization/createUserMembership.ldif

EXPOSE 389

#CMD slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats
