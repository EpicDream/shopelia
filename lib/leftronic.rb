require 'net/http'
require 'net/https'
require 'rubygems'
require 'json'

class Leftronic

  ACCESS_KEY = "yiOeiGcux3ZuhdsWuVHJ"
  
  ALLOWED_COLORS = [:red, :yellow, :green, :blue, :purple]
  attr_accessor :key
  
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

  def notify_order order
    return if Rails.env.test?
    product = order_items.first.product
    Leftronic.new.push("shopelia_sound", {"html" => "<audio id='sound'><source src='https://www.shopelia.fr/sounds/order_#{order.state_name}.mp3' type='audio/mpeg'></audio><script>document.getElementById('sound').play();</script>"})
    Leftronic.new.push_text("shopelia_orders_#{order.state_name}", product.name, user.name, product.image_url)
  end
  
  protected

  def post(stream, params)
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

