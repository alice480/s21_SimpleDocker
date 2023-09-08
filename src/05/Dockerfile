FROM nginx

WORKDIR /home

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./fcgi_server.c .
COPY ./run.sh .

RUN apt-get update && apt install -y gcc spawn-fcgi libfcgi-dev \
    && gcc fcgi_server.c -o fcgi_server -lfcgi \
    && rm -rf /var/lib/apt/lists

ENTRYPOINT ["sh", "run.sh"]

USER nginx

HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1
