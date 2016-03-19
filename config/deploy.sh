#! /bin/bash

git pull
bundle install
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake assets:precompile
sudo service nginx restart
sudo restart puma-manager
sudo start puma app=/home/dev/workspace/convo
