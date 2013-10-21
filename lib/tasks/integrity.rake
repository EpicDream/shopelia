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
    
    desc "Verify integrity of Viking extraction for descriptions" 
    task :viking => :environment do
      stats = {}
      Product.where("updated_at > ? and viking_failure='f'", 12.hours.ago).each do |product|
        next if product.product_versions.available.count == 0
        stats[product.merchant_id] ||= {}
        stats[product.merchant_id][:total] ||= 0 
        stats[product.merchant_id][:missing] ||= 0 
        stats[product.merchant_id][:total] += 1
        if product.description.blank?
          stats[product.merchant_id][:missing] += 1
          stats[product.merchant_id][:urls] ||= []
          stats[product.merchant_id][:urls] << product.url
        end
      end
      stats.keys.each do |merchant_id|
        if stats[merchant_id][:missing] > stats[merchant_id][:total] / 3 && stats[merchant_id][:total] > 50
          Incident.create(
            :issue => "Viking",
            :description => "#{stats[merchant_id][:missing]} missing descriptions over #{stats[merchant_id][:total]} #{stats[merchant_id][:urls].join(',')}",
            :resource_type => 'Merchant',
            :resource_id => merchant_id,
            :severity => Incident::CRITICAL)          
        end
      end
    end

  end
end
