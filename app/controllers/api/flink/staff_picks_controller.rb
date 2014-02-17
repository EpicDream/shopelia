class Api::Flink::StaffPicksController < Api::Flink::BaseController
  
  def index
    render json: { flinkers: serialize(flinkers) }
  end
  
  private
  
  def flinkers
    country = params[:"x-country-iso"]
    flinkers = Flinker.publishers.with_looks.staff_pick
    country = Country::FRANCE if flinkers.of_country(country).count.zero?
    flinkers.of_country_or_universal(country)
  end
  
end
