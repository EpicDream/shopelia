class FlinkerAuthentication < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :flinker
  attr_accessible :provider,:uid,:token

  def self.fetch_data provider, access_token ,secret=nil
    begin
      if provider == "facebook"
        fb_user = FbGraph::User.me(access_token).fetch
        data =  {
            email: fb_user.email,
            uid: fb_user.identifier,
            username: fb_user.username
        }
      end
    rescue Exception => e
      Rails.logger.error("FBGRAPH #{access_token} #{fb_user.nil?}")
      if e.respond_to?(:code) && e.code == 400 || 401
        data = {:status => 401, :message => "you are not authorized to get data from #{provider.capitalize}"}
      else
        raise e
      end
    else
      data = data.merge(provider: provider, token: access_token, secret: secret)
    end
    data
  end

  def self.find_flinker_by_email_or_uid data
    flinker = FlinkerAuthentication.find_by_uid(data.id).flinker
    unless flinker
      flinker = Flinker.find_by_email(data.email)
    end
    flinker
  end

  def merge_account

  end

end
