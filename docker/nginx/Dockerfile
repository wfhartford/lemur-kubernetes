FROM ubuntu:16.04

ARG ARCHIVE_MIRROR=http://archive.ubuntu.com/
ARG SECURITY_MIRROR=http://security.ubuntu.com/
ARG NPM_REGISTRY=https://registry.npmjs.org/
ARG LEMUR_USER=netflix
ARG LEMUR_VERSION=master
ARG LEMUR_TARGET=develop

ENV LC_ALL=en_US.UTF-8

RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup \
 && sed -i "s@http://archive.ubuntu.com/@${ARCHIVE_MIRROR}@" /etc/apt/sources.list \
 && sed -i "s@http://security.ubuntu.com/@${SECURITY_MIRROR}@" /etc/apt/sources.list \
 && echo "registry=${NPM_REGISTRY}" > $HOME/.npmrc \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      git \
      build-essential \
      sudo \
      python3 \
      python3-pip \
      python3-dev \
      nodejs \
      npm \
      postgresql-contrib \
      libpq-dev \
      libssl-dev \
      libffi-dev \
      libsasl2-dev \
      libldap2-dev \
      nginx \
 && rm /etc/apt/sources.list \
 && mv /etc/apt/sources.list.backup /etc/apt/sources.list \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 \
 && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 1 \
 && apt-get clean -y \
 && locale-gen en_US.UTF-8 \
 && git config --global url."https://".insteadOf git:// \
 && cd /usr/local/src \
 && git clone https://github.com/${LEMUR_USER}/lemur.git \
 && cd lemur \
 && git checkout ${LEMUR_VERSION} \
 && pip install --upgrade pip virtualenv \
 && export PATH=/usr/local/src/lemur/venv/bin:${PATH} \
 && virtualenv -p python3 venv \
 && . venv/bin/activate \
 && make ${LEMUR_TARGET} \
 && mkdir /lemur-config \
 && ln -s /lemur-config/lemur.conf.py /usr/local/src/lemur/lemur.conf.py \
 && npm install --unsafe-perm \
 && node_modules/.bin/gulp build \
 && node_modules/.bin/gulp package \
 && apt-get purge -y \
      git \
      build-essential \
      python3 \
      python3-pip \
      python3-dev \
      nodejs \
      npm \
      postgresql-contrib \
      libpq-dev \
      libssl-dev \
      libffi-dev \
      libsasl2-dev \
      libldap2-dev \
 && apt-get autoremove -y \
 && rm -rf \
      /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/* \
      /usr/local/src/lemur/bower_components \
      /usr/local/src/lemur/node_modules \
 && mkdir /etc/nginx/ssl \
 && mv /usr/local/src/lemur/lemur/static/dist /tmp/ \
 && rm -rf /usr/local/src/lemur \
 && mkdir -p /usr/local/src/lemur/lemur/static \
 && mv /tmp/dist /usr/local/src/lemur/lemur/static

ADD server.crt /etc/nginx/ssl/
ADD server.key /etc/nginx/ssl/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

STOPSIGNAL SIGTERM

WORKDIR /

CMD ["nginx", "-g", "daemon off;"]
