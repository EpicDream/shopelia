#! /bin/bash

# This script may be called at first installation of Saturn.
# It will install all necessary software (NodeJS, Grunt, CasperJS, etc),
# initialize Saturn, and compile it.

if [[ `pwd` =~ "saturn/bin" ]]; then
  cd ..
fi

# NodeJS and Grunt
if ! which nodejs > /dev/null; then
  sudo apt-get install nodejs npm
fi
if ! which grunt > /dev/null; then
  sudo npm install -g grunt-cli
fi

# PhantomJS & CasperJS
if ! which phantomjs > /dev/null; then
  wget -P /tmp/ https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2
  tar xvjf /tmp/phantomjs-1.9.2-linux-x86_64.tar.bz2
  sudo cp /tmp/phantomjs-1.9.2-linux-x86_64/bin/phantomjs /usr/bin/phantomjs
  rm -r /tmp/phantomjs-1.9.2-linux-x86_64*
fi
if ! which casperjs > /dev/null; then
  sudo npm install -g casperjs
fi

# Saturn dirs and scripts
echo "Make Saturn logs directory..."
sudo mkdir -p /var/log/saturn/
sudo chown `whoami` /var/log/saturn/
echo "Set ./saturn script executable..."
chmod u+x ./bin/*

#
./bin/update.sh
