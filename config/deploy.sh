#! /bin/bash

git pull
RAILS_ENV=production bundle install
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake assets:precompile
sudo /home/dev/scripts/nginx-restart
sudo restart puma-manager
sudo start puma app=/home/dev/workspace/convo
