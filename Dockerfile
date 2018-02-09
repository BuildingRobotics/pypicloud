FROM phusion/baseimage:0.9.17

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
    #Change /data ownership
    chown -R /data

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

EXPOSE 6543
