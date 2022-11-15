#FROM eclipse-temurin:11-alpine as buildwar
FROM eclipse-temurin:11-alpine as buildwar
RUN cd /tmp \
  && apk update \
  && apk upgrade \
  && apk add --no-cache git \
  && git clone -b 6.6 --single-branch https://github.com/apereo/cas-overlay-template.git cas-overlay \
  && mkdir -p /tmp/cas-overlay/src/main/webapp
WORKDIR /tmp/cas-overlay
COPY src/ /tmp/cas-overlay/src
RUN  ./gradlew clean build

#FROM eclipse-temurin:11-alpine
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

ARG USER
ARG PASSWORD
WORKDIR /etc/cas/config
RUN   sed -i "s|user_name|$USER|g" application.yml
RUN   sed -i "s|password|$PASSWORD|g" application.yml

EXPOSE 8443
CMD [ "java", "-jar", "/root/cas.war" ]

#
#COPY etc/cas /etc/cas
#WORKDIR /etc/cas
#RUN keytool -genkey -noprompt -keystore thekeystore -storepass changeit -keypass changeit -validity 3650 \
#             -keysize 2048 -keyalg RSA -dname "CN=localhost, OU=MyOU, O=MyOrg, L=Somewhere, S=VA, C=US"
#RUN if [ -r /etc/cas/config/certificate.pem ]; then keytool -noprompt -importcert -keystore /usr/local/openjdk-11/lib/security/cacerts -storepass changeit \
#             -file /etc/cas/config/certificate.pem -alias "casclient"; fi
#WORKDIR /root
#COPY --from=buildwar /tmp/cas-overlay/build/libs/cas.war .
#EXPOSE 8443
#CMD [ "/usr/local/openjdk-11/bin/java", "-jar", "/root/cas.war" ]
