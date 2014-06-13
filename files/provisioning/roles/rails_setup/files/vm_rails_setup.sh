#!/bin/bash

# Restart postgres, required for some reason for connecting from host
# the first time VM is built
sudo service postgresql restart

# setup clean rails environment
su vagrant -l <<ACTIONS
cd /vagrant
bundle install --local
bundle exec rake db:reset
sudo bundle exec foreman export upstart /etc/init --user vagrant
ACTIONS

/sbin/initctl emit provisioned
start app
