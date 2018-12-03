FROM ubuntu:16.04

RUN apt-get -qq update && \
  apt-get -qq install -y --no-install-recommends curl git build-essential sudo \
    python3 python3-pip python3-dev \
    nodejs npm \
    postgresql postgresql-contrib \
    libpq-dev libssl-dev libffi-dev libsasl2-dev libldap2-dev && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
  update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
  update-alternatives --install /usr/bin/node node /usr/bin/nodejs 1 && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8

ENV LC_ALL=en_US.UTF-8

ENV LEMUR_VERSION=0.7.0 LEMUR_TARGET=release

# Install Lemur
RUN git config --global url."https://".insteadOf git:// &&\
  cd /usr/local/src &&\
  git clone https://github.com/netflix/lemur.git &&\
  cd lemur &&\
  git checkout ${LEMUR_VERSION} &&\
  pip install --upgrade pip virtualenv &&\
  export PATH=/usr/local/src/lemur/venv/bin:${PATH} &&\
  virtualenv -p python3 venv &&\
  . venv/bin/activate &&\
  make ${LEMUR_TARGET} &&\
  mkdir /lemur-config &&\
  ln -s /lemur-config/lemur.conf.py /usr/local/src/lemur/lemur.conf.py

WORKDIR /usr/local/src/lemur

# Create static files
RUN npm install --unsafe-perm && node_modules/.bin/gulp build && \
  node_modules/.bin/gulp package && \
  rm -r bower_components node_modules

ADD api-start.sh /usr/local/src/lemur/scripts/api-start.sh
RUN chmod +x /usr/local/src/lemur/scripts/api-start.sh

CMD ["/usr/local/src/lemur/scripts/api-start.sh"]
