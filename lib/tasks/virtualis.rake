namespace :shopelia do
  namespace :virtualis do
    desc "Retrieve Virtualis daily report"
    task :get_report => :environment do
      report_file = '/tmp/virtualis_report.csv'
      data = Virtualis::Report.parse(report_file)
      puts data.inspect
    end
  end
end
