FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV LC_ALL=C.UTF-8

USER root

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  automake \
  bsdmainutils \
  clamav-daemon \
  curl \
  exiftool \
  gcc \
  git \
  libclamunrar9 \
  libdpkg-perl \
  libffi-dev \
  libfuzzy-dev \
  libjansson-dev \
  libmagic-dev \
  libssl-dev \
  libtool \
  libusb-1.0-0-dev \
  make \
  p7zip-full \
  python3-dev \
  python3-pip \
  ssdeep \
  swig \
  tor \
  unrar \
  vim && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# ClamAV daemon post-configuration
RUN mkdir /var/run/clamav && \
  chown clamav:clamav /var/run/clamav && \
  chmod 777 /var/run/clamav && \
  sed -i 's/^DetectPUA .*$/DetectPUA true/' /etc/clamav/clamd.conf && \
  freshclam

# nonroot user
RUN groupadd -r nonroot && \
  useradd -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
  mkdir /home/nonroot && \
  chown -R nonroot:nonroot /home/nonroot && \
  chsh -s /bin/bash nonroot

USER nonroot
WORKDIR /home/nonroot

RUN pip3 install --user --upgrade pip && \
  pip3 install python-idb --user && \
  # viper installation
  git clone https://github.com/viper-framework/viper && \
  cd viper && pip3 install . --user && \
  echo "update-modules" | /home/nonroot/.local/bin/viper && \
  mkdir /home/nonroot/workdir && \
  sed -i 's/storage_path.*$/storage_path=\/home\/nonroot\/workdir/' /home/nonroot/.viper/viper.conf && \
  sed -i 's/host = .*$/host = 0.0.0.0/' /home/nonroot/.viper/viper.conf && \
  sed -i 's/#admin_username.*$/admin_username = admin/' /home/nonroot/.viper/viper.conf && \
  sed -i 's/#admin_password.*$/admin_password = admin/' /home/nonroot/.viper/viper.conf && \
  # viper-web installation
  cd && \
  git clone https://github.com/jdsnape/viper-web && \
  cd viper-web && pip3 install . --user

# port
EXPOSE 8080

# av daemon / viper-web bootstrapping
USER root

COPY bootstrap.sh /
RUN chown root:root /bootstrap.sh && \
  chmod +x /bootstrap.sh

CMD ["/bootstrap.sh"]
