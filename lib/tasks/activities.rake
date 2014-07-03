namespace :flink do
  namespace :activities do
    
    desc "remove activities older than 30 days"
    task :clean => :environment do
      sql = "delete from activities where created_at < '#{Time.now - 30.days}'"
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
