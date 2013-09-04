class MangoPayDriver

  CONFIG = "#{Rails.root}/lib/config/mangopay_#{Rails.env}.yml"

  def self.create_master_account
    if File.exist?(MangoPayDriver::CONFIG)
      { status:"error", message:"Master account already created" }
    else
      object = MangoPay::User.create({
          'Tag' => "Master Account",
          'Email' => "mangopay_master_account@shopelia.com",
          'FirstName' => "Shopelia",
          'LastName' => "SAS",
          'Nationality' => "fr",
          'Birthday' => 30.years.ago.to_i,
          'PersonType' => 'LEGAL_PERSONALITY',
          'CanRegisterMeanOfPayment' => true
      })
      if object["ID"].present?
        File.open(CONFIG, 'w') { |f| YAML.dump({"master_account_id" => object["ID"]}, f) }
        { status:"created" }
      else
        { status:"error", message:"Impossible to create mangopay user object: #{object.inspect}" }
      end
    end
  end

  def self.get_master_account_id
    if File.exist?(MangoPayDriver::CONFIG)
      config = YAML.load(File.open(CONFIG))
      config["master_account_id"]
    else
      nil
    end
  end

  def self.credit_master_account card, amount
    contribution = MangoPay::Contribution.create({
        'Tag' => "Contribution to master account",
        'UserID' => self.get_master_account_id,
        'WalletID' => 0,
        'Amount' => amount,
        'ReturnURL' => 'https://www.shopelia.fr/null'
      })
    if contribution['ID'].present?
      begin
        PaylineDriver.inject(card, contribution["PaymentURL"]) 
      rescue PaylineDriver::DriverError => e
        return { status:"error", message:"Impossible to inject payment card in Payline form: #{e.inspect}" }
      end
    else
      return { status:"error", message:"Impossible to create mangopay contribution object: #{contribution.inspect}" }
    end
      
    attempts = 0
    begin
      sleep 1 if attempts > 0
      c = MangoPay::Contribution.details(contribution['ID'])
      attempts += 1
    end while not c["IsCompleted"] || attempts > 10
  
    config = YAML.load(File.open(CONFIG))
    config['contributions'] ||= []
    config['contributions'] << c
    File.open(CONFIG, 'w') { |f| YAML.dump(config, f) }

    c
  end

  def self.get_master_account_balance
    u = MangoPay::User.details(MangoPayDriver.get_master_account_id)
    u['PersonalWalletAmount'].to_f / 100
  end
end