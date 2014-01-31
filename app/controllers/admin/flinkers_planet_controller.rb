class Admin::FlinkersPlanetController < Admin::AdminController
  
  def index
    @coordinates = Flinker.coordinates.to_json
    respond_to do |format|
      format.html
      format.json { render json:@coordinates , status:200 }
    end
  end
end
