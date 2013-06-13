require 'net/http'
require 'net/https'
require 'rubygems'
require 'json'

class Leftronic

  ACCESS_KEY = "yiOeiGcux3ZuhdsWuVHJ" 
  ALLOWED_COLORS = [:red, :yellow, :green, :blue, :purple]
  attr_accessor :key 

  def notify_order order
    return if order.order_items.blank?
    product = order.order_items.first.product
    if order.state_name.eql?("failed") && order.error_code.eql?("user")
      sound = "canceled" 
    else
      sound = order.state_name
    end
    push("shopelia_sound", {"html" => "<audio id='sound'><source src='https://www.shopelia.fr/sounds/order_#{sound}.mp3' type='audio/mpeg'></audio><script>document.getElementById('sound').play();</script>"})
    push_text("shopelia_orders_#{order.state_name}", product.name, order.user.name, product.image_url)
  end
  
  def notify_users_count
    push_number("shopelia_users_count", User.count)
  end

  def clear_board
    clear("shopelia_sound")
    clear("shopelia_orders_pending")
    clear("shopelia_orders_processing")
    clear("shopelia_orders_completed")
    clear("shopelia_orders_aborted")    
  end

  def url=(url)
    @url = URI(url.to_s)
  end
  
  def url
    @url.to_s
  end

  def initialize(key=ACCESS_KEY, url='https://www.leftronic.com/customSend/')
    @key = key
    self.url = url
  end

  # Push anything to a widget
  def push(stream, object)
    post stream, object
  end

  # Push a Number to a widget
  def push_number(stream, point)
    post stream, point
  end

  # Push a geographic location (latitude and longitude) to a Map widget
  def push_geo(stream, lat, long, color=nil)
    post stream, 'latitude' => lat, 'longitude' => long, 'color' => color
  end

  # Push a title and message to a Text Feed widget
  def push_text(stream, title, message, url=nil)
    post stream, 'title' => title, 'msg' => message, 'imgUrl' => url
  end

  # Push a hash to a Leaderboard widget
  def push_leaderboard(stream, hash)
    leaderboard = hash.inject([]) do |array, (key, value)|
      array << {'name' => key, 'value' => value}
    end
    post stream, 'leaderboard' => leaderboard
  end

  # Push an array to a List widget
  def push_list(stream, *array)
    post stream, 'list' => array.flatten.map{|item| {'listItem' => item}}
  end

  def clear(stream)
    post stream, 'clear'
  end

  
  protected

  def post(stream, params)
    return unless Rails.env.production?
    request = build_request(stream, params)
    connection = build_connection
    connection.start{|http| http.request request}
    params
  end

  def build_request(stream, params)
    request = Net::HTTP::Post.new @url.request_uri
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    if params.eql?('clear')
      request.body = {
        'accessKey' => @key,
        'streamName' => stream,
        'command' => 'clear'
      }.to_json
    else
      request.body = {
        'accessKey' => @key,
        'streamName' => stream,
        'point' => params
      }.to_json
    end
    request
  end

  def build_connection # NOTE: Does not open the connection
    connection = Net::HTTP.new @url.host, @url.port
    if @url.scheme == 'https'
      connection.use_ssl = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    connection
  end
end

