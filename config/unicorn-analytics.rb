worker_processes 4
working_directory "/home/shopelia/flink-analytics"
listen "/var/run/shopelia-unicorn/unicorn_analytics_master.sock", :backlog => 2048
user("shopelia","shopelia")
client_body_buffer_size 67108864
timeout 20
pid "/var/run/shopelia-unicorn/flink-analytics-unicorn.pid"
stderr_path "/var/log/shopelia-unicorn/flink-analytics-unicorn.stderr.log"
stdout_path "/var/log/shopelia-unicorn/flink-analytics-unicorn.stdout.log"
preload_app true

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  
  sleep 0.2
end

after_fork do |server, worker|
  addr = "/var/run/shopelia-unicorn/unicorn_analytics_#{worker.nr}"
  server.listen(addr, :tries => 0, :delay => 0, :backlog => 2048)

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

