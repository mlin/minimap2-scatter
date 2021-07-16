FROM ubuntu:21.04
RUN apt-get -qq update && apt-get -qq install -y seqkit
ADD minimap2/minimap2 /usr/local/bin/
