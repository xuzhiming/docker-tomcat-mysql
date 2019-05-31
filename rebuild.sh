#! /bin/bash
docker stop tse
docker rm tse
docker build -t dutycall/tse .
docker run --name tse -d  -p8081:8080 -p3307:3306 -p9200:9200  dutycall/tse