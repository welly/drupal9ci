FROM drupal:9-apache

RUN apt-get update && apt-get install -y \
  git \
  imagemagick \
  libmagickwand-dev \
  mariadb-client \
  rsync \
  sudo \
  unzip \
  vim \
  wget && \
  docker-php-ext-install bcmath && \
  docker-php-ext-install intl && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install pdo && \
  docker-php-ext-install pdo_mysql

# Remove the memory limit for the CLI only.
RUN echo 'memory_limit = -1' > /usr/local/etc/php/php-cli.ini

# Remove the vanilla Drupal project that comes with this image.
RUN rm -rf ..?* .[!.]* *

# Install composer.
COPY scripts/composer-installer.sh /tmp/composer-installer.sh
RUN chmod +x /tmp/composer-installer.sh && \
    /tmp/composer-installer.sh && \
    mv composer.phar /usr/local/bin/composer

# Install XDebug.
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

# Install Robo CI.
RUN wget https://robo.li/robo.phar && \
    chmod +x robo.phar && mv robo.phar /usr/local/bin/robo

# Install node.
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
    apt install -y nodejs npm xvfb libgtk-3-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2

# Install Dockerize.
ENV DOCKERIZE_VERSION v0.6.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install Chrome browser.
RUN apt-get install --yes gnupg2 apt-transport-https && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install --yes google-chrome-unstable
