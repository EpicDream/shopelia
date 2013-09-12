class Api::Showcase::Products::SearchController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params

  def index
    if @ean
      prixing = Prixing::Product.get(@ean)
      if prixing.empty? || prixing.is_a?(Hash)
        render :json => {}
      else
        render :json => PrixingWrapper.convert(prixing)
      end
    else
      render :json => {}
    end
  end

  private
  
  def prepare_params
    @ean = params[:ean]
  end

end