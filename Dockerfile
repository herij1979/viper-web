FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  git \
  gcc \
  python3-dev \
  python3-pip \
  libssl-dev \
  swig \
  libffi-dev \
  ssdeep \
  libfuzzy-dev \
  unrar \
  p7zip-full \
  exiftool \
  clamav-daemon \
  tor \
  libdpkg-perl \
  bsdmainutils \
  curl \
  automake \
  libtool \
  make \
  libjansson-dev \
  libmagic-dev \
  libusb-1.0-0-dev

RUN freshclam && \
  service clamav-daemon start

RUN groupadd -r nonroot && \
  useradd -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
  mkdir /home/nonroot && \
  chown -R nonroot:nonroot /home/nonroot && \
  chsh -s /bin/bash nonroot

USER nonroot
WORKDIR /home/nonroot

RUN pip3 install --user --upgrade pip && \
  pip3 install python-idb --user

RUN git clone https://github.com/viper-framework/viper && \
  cd viper && pip3 install . --user && \
  echo "update-modules" | /home/nonroot/.local/bin/viper && \
  cd && \
  git clone https://github.com/jdsnape/viper-web && \
  cd viper-web && pip3 install . --user

RUN sed -i 's/host = .*$/host = 0.0.0.0/' /home/nonroot/.viper/viper.conf && \
  sed -i 's/#admin_username.*$/admin_username = admin/' /home/nonroot/.viper/viper.conf && \
  sed -i 's/#admin_password.*$/admin_password = admin/' /home/nonroot/.viper/viper.conf

EXPOSE 8080
WORKDIR /home/nonroot/viper-web
CMD /home/nonroot/viper-web/viper-web
