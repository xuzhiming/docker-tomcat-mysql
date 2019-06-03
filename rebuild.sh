#! /bin/bash
docker stop tse
docker rm tse
docker build -t dutycall/tse .
docker run --name tse -d -v /Users/xzm/dev/dockerDev/share:/usr/Downloads -p8081:8080 -p3310:3306 -p9200:9200 -p9300:9300  dutycall/tse
