require 'geocoder'

class FlinkerCoordinatesWorker
  include Sidekiq::Worker
  
  def perform flinker_id
    flinker = Flinker.find(flinker_id)
    flinker.lat, flinker.lng = Geocoder.coordinates(flinker.last_sign_in_ip)
    flinker.save
  end
end
