#!/bin/bash

gcc fcgi_server.c -o fcgi_server -lfcgi
spawn-fcgi -p 8080 ./fcgi_server
service nginx start
tail -f /dev/null
