FROM eclipse-temurin:11-alpine as buildwar
RUN cd /tmp \
  && apk update \
  && apk upgrade \
  && apk add --no-cache git \
  && git clone -b 6.6 --single-branch https://github.com/ahettlin/cas-overlay-template-ldap.git cas-overlay \
  && mkdir -p /tmp/cas-overlay/src/main/webapp
WORKDIR /tmp/cas-overlay
COPY src/ /tmp/cas-overlay/src
RUN  ./gradlew clean build

FROM eclipse-temurin:11-alpine
RUN mkdir /etc/cas
FROM eclipse-temurin:11-alpine
RUN mkdir /etc/cas \
  && cd /etc/cas \
  && keytool -genkey -noprompt -keystore thekeystore -storepass changeit -keypass changeit -validity 3650 \
             -keysize 2048 -keyalg RSA -dname "CN=localhost, OU=MyOU, O=MyOrg, L=Somewhere, S=VA, C=US"
RUN if [ -r /etc/cas/config/certificate.pem ]; then \
       keytool -noprompt -importcert -keystore /etc/ssl/certs/java/cacerts -storepass changeit \
               -file /etc/cas/config/certificate.pem -alias "casclient"; \
    fi
WORKDIR /root
COPY --from=buildwar /tmp/cas-overlay/build/libs/cas.war .
COPY etc/cas /etc/cas

ARG LDAP_PORT
ARG LDAP_ADMIN_PASSWORD
WORKDIR /etc/cas/config
RUN   sed -i "s|ldap_port|$LDAP_PORT|g" application.yml
RUN   sed -i "s|ldap_admin_password|$LDAP_ADMIN_PASSWORD|g" application.yml

EXPOSE 8443
CMD [ "java", "-jar", "/root/cas.war", "-Dcas.log.level=debug" ]