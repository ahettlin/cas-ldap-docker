CAS Docker Overlay
==================
Uses gradle to build CAS 6.x 

# Docker Compose setup using a multi-stage build:
* First stage builds a Docker image that:
  * clones https://github.com/apereo/cas-overlay-template
  * copies the src (local overlay) tree into it
  * builds cas.war
* Second stage runs CAS in a Docker container
  * copies the directory etc/cas into the container at /etc/cas
  * generates a self-signed keystore for CAS to use at startup
  * copies the cas.war file from the first stage
  * exposes port 8443
  * runs /usr/bin/java -jar cas.war (using the embedded Tocmat server)

To use
=====
* To build & run CAS in Docker type:
```docker-compose up --force-recreate```. If you have changed anything in the Dockerfile, application.yml, or .env files, use this instead ```docker-compose up --force-recreate --build cas```. If you want to be able to close the terminal and keep the container running, add the ```-d``` argument.

* Open up a page at https://localhost:8443/cas/login and login as any user defined in the LDAP server

* Type ctrl-c to exit (if not using ```-d```), then type this to cleanup:
```docker-compose down --rmi all```
