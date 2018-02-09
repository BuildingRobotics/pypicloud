FROM phusion/baseimage:0.9.17

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install packages required
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y \
    libldap2-dev \
    libsasl2-dev \
    python-pip \
    python2.7-dev \
    && pip install virtualenv
RUN virtualenv /env && \
    /env/bin/pip install \
    pastescript \
    redis \
    requests \
    uwsgi \
    waitress

# Install pypicloud
COPY ./ /app/
RUN /env/bin/pip install /app/

# Add the startup service
RUN mkdir -p /etc/my_init.d && \
    printf "#!/bin/sh\n/env/bin/pserve /app/config.ini" > /etc/my_init.d/pypicloud-uwsgi.sh && \
    chmod +x /etc/my_init.d/pypicloud-uwsgi.sh && \
    #Create /data own by www-data for pypicloud.db
    mkdir /data && \
    chown -R www-data:www-data /data && \
    #Allow www-data access container environment
    chown -R root:www-data /etc/container_environment && \
    chmod -R 770 /etc/container_environment && \
    chmod 660 /etc/container_environment/* && \
    chown www-data:docker_env /etc/container_environment.sh && \
    chown www-data:docker_env /etc/container_environment.json

EXPOSE 6543
