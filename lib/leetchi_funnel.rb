# -*- encoding : utf-8 -*-
module LeetchiFunnel

  def self.bill order
    return if Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"

    # Ensure expected value is equal to prepared value
    if order.expected_price_total != order.prepared_price_total
      return error "Order expected total price and prepared total price are not equal"
    end    
    
    # Ensure value of billing is in acceptable range
    if order.prepared_price_total < 5 || order.prepared_price_total > 200
      return error "Order billing value should be beetwen 5€ and 200€"
    end
    
    # Ensure we are in billing state
    if order.state != :billing
      return error "Order is not in billing state"
    end
    
    # Ensure order hasn't already a contribution id
    if order.leetchi_contribution_id.present?
      return error "Order has already been billed on Leetchi"
    end
    
    # Create leetchi user object if necessary
    if order.user.leetchi_id.nil?
      user = order.user
      remote_user = Leetchi::User.create({
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
        user.update_attribute :leetchi_id, remote_user["ID"].to_i
      else
        return error "Impossible to create leetchi user object", remote_user
      end
    end
    
    # Create a wallet and attach it to order
    if order.leetchi_wallet_id.nil?
      wallet = Leetchi::Wallet.create({
          'Tag' => order.uuid,
          'Owners' => [order.user.leetchi_id]
      })
      if wallet["ID"].present?
        order.update_attribute :leetchi_wallet_id, wallet["ID"].to_i
      else
        return error "Impossible to create leetchi wallet object", wallet
      end
    end

    # Create payment card leetchi object if necessary
    if order.payment_card.leetchi_id.nil?
      card = order.payment_card
      remote_card = Leetchi::Card.create({
          'Tag' => card.id.to_s,
          'OwnerID' => card.user.leetchi_id,
          'ReturnURL' => 'https://www.shopelia.fr/null'
      })
      if remote_card['ID'].present?
        # If API is stubbed, skip card injection
        unless Rails.env.test? && File.exist?("#{Rails.root}/test/fixtures/cassettes/leetchi.yml")
          begin
            PaylineDriver.inject(card,remote_card["RedirectURL"]) 
          rescue PaylineDriver::DriverError => e
            return error "Impossible to inject payment card in Payline form", e
          end
        end
      else
        return error "Impossible to create leetchi payment card object", remote_card
      end
      
      # Wait for card approval
      attempts = 0
      begin
        sleep 1 if attempts > 0
        check_card = Leetchi::Card.details(remote_card['ID'])
        attempts += 1
      end while not (check_card["CardNumber"] || "").length == 16 || attempts > 30
    
      if (check_card["CardNumber"] || "").length == 16
        card.update_attribute :leetchi_id, remote_card["ID"].to_i
      else
        Leetchi::Card.delete(remote_card["ID"])
        return error "Leetchi card injection from Payline timed out", check_card
      end
    end
 
    # Initiate an immediate contribution
    if order.payment_card.leetchi_id.present?
      contribution = Leetchi::ImmediateContribution.create({
        'Tag' => order.uuid,
        'UserID' => order.user.leetchi_id,
        'WalletID' => order.leetchi_wallet_id,
        'PaymentCardID' => order.payment_card.leetchi_id,
        'Amount' => (order.prepared_price_total*100).to_i
      })
      if contribution['ID'].present?
        order.update_attributes(
          :leetchi_contribution_id => contribution['ID'],
          :leetchi_contribution_amount => contribution['Amount'],
          :leetchi_contribution_status => contribution['IsSucceeded'] ? "success" : "error"
        )
        return success    
      else
        return error "Impossible to create leetchi immediate contribution object", contribution
      end   
    end

    return error "Billing failure in funnel. Something went wrong"
  end

  private

  def self.error message, object=nil
    {"Status" => "error", "Error" => message, "Object" => object}
  end
  
  def self.success
    {"Status" => "success"}
  end
  
end
