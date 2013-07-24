# -*- encoding : utf-8 -*-
module MangoPayFunnel

  #
  # Bill a user and contrbute to its wallet
  #
  def self.bill order
    return if Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"

    # Ensure expected value is equal to prepared value
    if order.expected_price_total < order.prepared_price_total
      return error "Order prepared price total is higher than expected one"
    end    
    
    # Ensure value of billing is in acceptable range
    if order.prepared_price_total < 5 || order.prepared_price_total > 400
      return error "Order billing value should be beetwen 5€ and 400€"
    end
    
    # Ensure we are in billing state
    if order.state != :billing
      return error "Order is not in billing state"
    end
    
    # Ensure order hasn't already a contribution id
    if order.mangopay_contribution_id.present?
      return error "Order has already been billed on MangoPay"
    end
    
    # Create mangopay user object if necessary
    if order.user.mangopay_id.nil?
      user = order.user
      remote_user = MangoPay::User.create({
          'Tag' => Rails.env.test? ? "User test" : user.id.to_s,
          'Email' => user.email,
          'FirstName' => user.first_name,
          'LastName' => user.last_name,
          'Nationality' => user.nationality.nil? ? "fr" : user.nationality.iso,
          'Birthday' => user.birthdate.nil? ? 30.years.ago.to_i : user.birthdate.to_i,
          'PersonType' => 'NATURAL_PERSON',
          'CanRegisterMeanOfPayment' => true,
          'IP' => user.ip_address
      })
      if remote_user["ID"].present?
        user.update_attribute :mangopay_id, remote_user["ID"].to_i
      else
        return error "Impossible to create mangopay user object", remote_user
      end
    end
    
    # Create a wallet and attach it to order
    if order.mangopay_wallet_id.nil?
      wallet = MangoPay::Wallet.create({
          'Tag' => order.uuid,
          'Owners' => [order.user.mangopay_id]
      })
      if wallet["ID"].present?
        order.update_attribute :mangopay_wallet_id, wallet["ID"].to_i
      else
        return error "Impossible to create mangopay wallet object", wallet
      end
    end

    # Create payment card mangopay object if necessary
    if order.payment_card.mangopay_id.nil?
      card = order.payment_card
      remote_card = MangoPay::Card.create({
          'Tag' => card.id.to_s,
          'OwnerID' => card.user.mangopay_id,
          'ReturnURL' => 'https://www.shopelia.fr/null'
      })
      if remote_card['ID'].present?
        # If API is stubbed, skip card injectionapp/serializers/product_serializer.rb
        unless Rails.env.test? && File.exist?("#{Rails.root}/test/cassettes/mangopay.yml")
          begin
            PaylineDriver.inject(card,remote_card["RedirectURL"]) 
          rescue PaylineDriver::DriverError => e
            return error "Impossible to inject payment card in Payline form", e
          end
        end
      else
        return error "Impossible to create mangopay payment card object", remote_card
      end
      
      # Wait for card approval
      attempts = 0
      begin
        sleep 1 if attempts > 0
        check_card = MangoPay::Card.details(remote_card['ID'])
        attempts += 1
      end while not (check_card["CardNumber"] || "").length == 16 || attempts > 30
    
      if (check_card["CardNumber"] || "").length == 16
        card.update_attribute :mangopay_id, remote_card["ID"].to_i
      else
        MangoPay::Card.delete(remote_card["ID"])
        return error "MangoPay card injection from Payline timed out", check_card
      end
    end
 
    # Initiate an immediate contribution
    if order.payment_card.mangopay_id.present?
      contribution = MangoPay::ImmediateContribution.create({
        'Tag' => order.uuid,
        'UserID' => order.user.mangopay_id,
        'WalletID' => order.mangopay_wallet_id,
        'PaymentCardID' => order.payment_card.mangopay_id,
        'Amount' => (order.prepared_price_total*100).to_i
      })
      if contribution['ID'].present?
        order.update_attributes(
          :mangopay_contribution_id => contribution['ID'],
          :mangopay_contribution_amount => contribution['Amount'],
          :mangopay_contribution_status => contribution['IsSucceeded'] ? "success" : "error",
          :mangopay_contribution_message => contribution['AnswerMessage']
        )
        return success    
      elsif contribution['Type'] == "PaymentSystem"
        order.update_attributes(
          :mangopay_contribution_status => "error",
          :mangopay_contribution_message => "#{contribution['UserMessage']} #{contribution['TechnicalMessage']}"
        )
        return success        
      else
        return error "Impossible to create mangopay immediate contribution object", contribution
      end   
    end

    return error "Billing failure in funnel. Something went wrong"
  end

  #
  # Generate an Amazon Voucher from a wallet
  #
  def self.voucher order, store="FR"
    return if Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"

    if !order.mangopay_contribution_id.present? || !order.mangopay_wallet_id.present?
      return error "Order must have a mangopay wallet and contribution"
    end
    
    # Check that wallet has exactly the needed amount
    amount = (order.prepared_price_total*100).to_i
    wallet = MangoPay::Wallet.details(order.mangopay_wallet_id)
    if wallet['Amount'] != amount
      return error "Wallet must have exactly the requested amount (has #{wallet['Amount']} but need #{amount}"
    end
    
    voucher = MangoPay::AmazonVoucher.create({
        'Tag' => order.uuid,
        'UserID' => order.user.mangopay_id,
        'WalletID' => order.mangopay_wallet_id,
        'Amount' => amount,
        'Store' => store
      })
    if voucher['ID'].present?
      order.update_attributes(
        :mangopay_amazon_voucher_id => voucher['ID'],
        :mangopay_amazon_voucher_code => voucher['VoucherCode']
      )
      return success          
    else
      return error "Impossible to create amazon voucher", voucher
    end
  end


  private

  def self.error message, object=nil
    if object.nil?
      {"Status" => "error", "Error" => message}
    else
      {"Status" => "error", "Error" => "#{message} #{object.inspect}"}
    end
  end
  
  def self.success
    {"Status" => "success"}
  end
  
end
