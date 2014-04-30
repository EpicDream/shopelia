class Mailchimper
  API_KEY = "7b99b1f5e7477e1423c78cd74827363a-us3"
  
  def initialize
    @gibbon = Gibbon::API.new(API_KEY)
  end
  
  def add_subscribers_to_list emails, list_name
    list = @gibbon.lists.list({:filters => {:list_name => list_name}})
    list_id = list["data"].first["id"]
    @gibbon.lists.subscribe({
      :id => list_id, 
      :email => {:email => emails.first}}
    )
  end
  
  def assign_list_to_campaign
    
  end
  
  def send_campaign title
    campaigns = @gibbon.campaigns.list({:filters => {:title => title}})
    #assert campaigns["total"]==1
    cid = campaigns["data"].first["id"]
    ready = @gibbon.campaigns.ready(cid:cid)["is_ready"]
    if ready
      response = @gibbon.campaigns.send(cid:cid)
      raise unless response["complete"]
    else
    end
  rescue
    Rails.logger.error "Crash on campaign send #{title}"
  end
end