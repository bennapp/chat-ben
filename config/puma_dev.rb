workers 1
threads 1, 10

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

port 3000

pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
