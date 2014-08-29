#!/bin/bash

# Restart postgres, required for some reason for connecting from host
# the first time VM is built
sudo service postgresql restart

# setup clean rails environment
su vagrant -l <<ACTIONS
cd /vagrant
bundle install --local
sudo bundle exec foreman export upstart /etc/init --user vagrant
ACTIONS

# start or restart app as necessary
stop app >/dev/null || true
start app
