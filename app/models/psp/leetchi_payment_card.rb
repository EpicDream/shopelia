class Psp::LeetchiPaymentCard < Psp::LeetchiWrapper
  CARD_RETURN_URL = 'http://www.leetchi.com'
  
  def create card
    remote_card = Leetchi::Card.create({
        'Tag' => card.id.to_s,
        'OwnerID' => card.user.leetchi_id,
        'ReturnURL' => CARD_RETURN_URL
    })
    card.update_column "leetchi_created_at", Time.now
    
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
          card.update_column :leetchi_id, remote_card["ID"].to_i
          return true
        else
          time_out_error
          Leetchi::Card.delete remote_card["ID"]
        end
        
      rescue PaylineDriver::DriverError => e
        card_injection_error e.error
        Leetchi::Card.delete remote_card["ID"]
      end

    else
      remote_error remote_card
    end
    false
  end

  def destroy card
    Leetchi::Card.delete(card.leetchi_id)
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

