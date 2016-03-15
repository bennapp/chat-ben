workers 1
threads 1, 10

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

# stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

stdout_redirect '/Users/bennappier/workspace/convo/log/stdout', '/Users/bennappier/workspace/convo/log/stderr'
stdout_redirect '/Users/bennappier/workspace/convo/log/stdout', '/Users/bennappier/workspace/convo/log/stderr', true

port 3000

pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"

# Set up socket location
# bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging

# Set master PID and state locations

# activate_control_app

# on_worker_boot do
#   require "active_record"
#   ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
#   ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
# end