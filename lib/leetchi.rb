module Leetchi

  def bill order
    return if Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"

    # Ensure expected value is equal to prepared value
    if order.excepted_price_total != order.prepared_price_total
      return {'Error':'Order expected total price and prepared total price are not equal'}
    end    
    
    # Ensure value of billing is in acceptable range
    if order.prepared_price_total < 5 || order.prepared_price_total > 200
      return {'Error':'Order billing value should be beetwen 5€ and 200€'}
    end
    
    # Ensure we are in billing state
    if order.state == :billing
      return {'Error':'Order is not in billing state'}
    end
    
    # Ensure order hasn't already a contribution id
    if order.contribution_id.present?
      return {'Error':'Order has already been billed on Leetchi'}
    end
    
    # Create leetchi user object if necessary
    if !order.user.leetchi_created?
      user = order.user
      remote_user = Leetchi::User.create({
          'Tag' => user.id.to_s,
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
        user.update_column :leetchi_id, remote_user["ID"].to_i
      else
        return {'Error':'Impossible to create leetchi user object','Object':remote_user}
      end
    end
    
    # Create a wallet and attach it to order
    if order.leetchi_wallet_id.nil?
      wallet = Leetchi::Wallet.create({
          'Tag' => "Order #{order.uuid}",
          'Owners' => [order.user.leetchi_id]
      })
      if wallet["ID"].present?
        order.update_attribute :leetchi_wallet_it, wallet["ID"].to_i
      else
        return {'Error':'Impossible to create leetchi wallet object','Object':wallet}
      end
    end
    
    # If payment card hasn't a leetchi object attached, initiate a contribution
    if !order.payment_card.leetchi_created?
      contribution = Leetchi::Contribution.create({
        'Tag' => "Order #{order.uuid}",
        'UserID' => order.user.leetchi_id,
        'WalletID' => order.leetchi_wallet_id,
        'Amount' => (order.prepared_price_total*100).to_i,
        'RegisterMeanOfPayment' => true,
        'ReturnURL' => 'https://www.shopelia.fr/null'
      )}
      if contribution['ID'].present?
        order.update_attribute :leetchi_contribution_id, contribution['ID']
      else
        return {'Error':'Impossible to create leetchi contribution object','Object':contribution}
      end
      
      # Inject payment card details
      begin
        PaylineDriver.inject(order.payment_card,contribution["PaymentURL"])      
      rescue PaylineDriver::DriverError => e
        {'Error':'Impossible to inject payment card in Payline form','Object':e}
      end
    end
      
    # If payment card is already a leetchi object, initiate an immediate contribution
    if order.payment_card.leetchi_created?
      contribution = Leetchi::ImmetiateContribution.create({
        'Tag' => "Order #{order.uuid}",
        'UserID' => order.user.leetchi_id,
        'WalletID' => order.leetchi_wallet_id,
        'PaymentCardID' => order.payment_card.leetchi_id,
        'Amount' => (order.prepared_price_total*100).to_i,
        'RegisterMeanOfPayment' => true,
        'ReturnURL' => 'https://www.shopelia.fr/null'
      )}
      if contribution['ID'].present?
        order.update_attribute :leetchi_contribution_id, contribution['ID']
      else
        return {'Error':'Impossible to create leetchi immediate contribution object','Object':contribution}
      end   
    end
       
  end

end
