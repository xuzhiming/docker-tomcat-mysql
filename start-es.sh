#!/bin/bash
exec chown -R elsearch $ES_HOME
exec su elsearch -c "$ES_HOME/bin/elasticsearch -d"
