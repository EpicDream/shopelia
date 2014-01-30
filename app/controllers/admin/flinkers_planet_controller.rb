class Admin::FlinkersPlanetController < Admin::AdminController
  
  def index
    @coordinates = Flinker.coordinates.to_json
    puts @coordinates.inspect
  end
end
