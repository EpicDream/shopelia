class Psp::LeetchiPaymentCard < Psp::LeetchiWrapper
  CARD_RETURN_URL = 'http://www.leetchi.com'
  
  def create card
    remote_card = Leetchi::Card.create({
        'Tag' => card.id.to_s,
        'OwnerID' => card.user.leetchi.remote_user_id,
        'ReturnURL' => CARD_RETURN_URL
    })
    
    if remote_card["ID"].present?
      begin
      
        # If API is stubbed, skip card injection
        unless Rails.env.test? && File.exist?("#{Rails.root}/test/fixtures/cassettes/card.yml")
          PaylineDriver.inject(card,remote_card["RedirectURL"])
        end
        
        # Wait for card approval
        attemps = 0
        begin
          sleep 1
          check_card = Leetchi::Card.details(remote_card['ID'])
          attemps += 1
        end while not (check_card["CardNumber"] || "").length == 16 || attemps > 30
      
        if (check_card["CardNumber"] || "").length == 16
          psp_card = PspPaymentCard.new(
            :psp_id => @psp.id, 
            :payment_card_id => card.id, 
            :remote_payment_card_id => remote_card["ID"].to_i)
          if psp_card.save
            return true
          else
            local_error psp_card
          end
        else
          time_out_error
        end
        
      rescue PaylineDriver::DriverError => e
        card_injection_error e.error
      end

    else
      remote_error remote_card
    end
    false
  end

  def destroy card
    remote_card = Leetchi::Card.delete(card.leetchi.remote_payment_card_id)
    if remote_card.eql?("\"OK\"")
      true
    else
      remote_error remote_card
      false
    end
  end

  def time_out_error
     @errors = { :origin => "remote", 
                 :message => "Card accepted by PSP but not validated by Leetchi after allowed retries" }
  end

  def card_injection_error message
     @errors = { :origin => "injection", 
                 :message => message }
  end

end

