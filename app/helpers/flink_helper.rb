module FlinkHelper

  def flink_appstore_url
    "https://itunes.apple.com/fr/app/flink-mode-street-des-meilleures/id798552697?mt=8&uo=4"
  end

  def flink_instagram_url
    "http://instagram.com/flinkHQ"
  end

  def flink_facebook_url
    "http://facebook.com/flinkhq"
  end

  def flink_twitter_url
    "http://twitter.com/flinkhq"
  end

  def flink_deeplink_for_look look
    "http://deeplink.me/#{Rails.configuration.deeplink_host}/looks/#{look.uuid}"
  end

end