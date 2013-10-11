which npm > /dev/null || echo "First install nodejs and npm."
which grunt > /dev/null || sudo npm install -g grunt-cli
npm install
chmod u+x ./saturn
grunt prod
