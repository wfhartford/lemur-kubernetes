FROM quay.io/wfhartford/lemur:latest

RUN apt-get -qq update && \
  apt-get -qq install -y --no-install-recommends nginx && \
  mkdir /etc/nginx/ssl

ADD server.crt /etc/nginx/ssl/
ADD server.key /etc/nginx/ssl/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

STOPSIGNAL SIGTERM

WORKDIR /

CMD ["nginx", "-g", "daemon off;"]
