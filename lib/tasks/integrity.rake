namespace :shopelia do
  namespace :integrity do
    
    desc "Verify integrity of daily MangoPay report"
    task :mangopay_report => :environment do
      report = File.read("tmp/mangopay_report.csv")
      result = Integrity::MangoPay.verify_report(report)
      if result.empty?
        puts "OK"
      else
        puts "ERROR !"
        puts result.join("\n")
      end
    end

  end
end
