#!/bin/bash

spawn-fcgi -p 8080 ./fcgi_server
service nginx start
tail -f /dev/null
