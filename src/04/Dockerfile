FROM nginx

WORKDIR /home

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./fcgi_server.c .
COPY ./run.sh .

RUN apt-get update && apt install -y gcc spawn-fcgi libfcgi-dev \
    && gcc fcgi_server.c -o fcgi_server -lfcgi

ENTRYPOINT ["sh", "run.sh"]
