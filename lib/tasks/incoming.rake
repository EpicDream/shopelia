namespace :shopelia do
  namespace :email do
    desc "Process incoming emails"
    task :process_incoming => :environment do
      maildir = Maildir.new('/home/shopelia/Maildir', false)
      maildir.list(:new).each do |message|
        mail = Mail.new(message.data)
        next unless mail.to.first == 'mangopay-report@shopelia.com'
        if mail.attachments.size != 1
          puts "Error with message #{message.key}: it has #{mail.attachments.size} attachments"
          next
        end
        attachment = mail.attachments.first
        filename = attachment.filename
        filepath = '/tmp/' + filename
        begin
          File.open(filepath, "w+b", 0644) {|f| f.write attachment.body.decoded}
        rescue Exception => e 
          puts "Error with message #{message.key}: Unable to save attachement to #{filepath} because #{e.message}"
          next
        end
        report = File.read(filepath).gsub(/\A.+?textbox/, 'textbox').gsub(/\r/,'')
        result = Integrity::MangoPay.verify_report(report)
        if result.empty?
          File.unlink(filepath)
          message.destroy
        else
          puts "Mangopay Report ERROR in message #{message.key}, attachement #{filepath}"
          puts result.join("\n")
          message.process
        end
      end
    end
  end
end

