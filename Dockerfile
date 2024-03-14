FROM ubuntu:latest

# instal dependencies
RUN apt-get update \
      && apt-get install -y \
          bison \
          flex \
          wget \
          unzip \
          make


# instal filebench
RUN wget https://github.com/filebench/filebench/releases/download/1.5-alpha3/filebench-1.5-alpha3.zip \
      && unzip filebench-1.5-alpha3.zip \
      && cd filebench-1.5-alpha3 \
      && ./configure \
      && make \
      && make install


# keep the container running in detached mode
CMD ["tail", "-f", "/dev/null"]