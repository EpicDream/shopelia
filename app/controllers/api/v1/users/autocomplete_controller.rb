class Api::V1::Users::AutocompleteController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :process_params

  api :POST, "/users/autocomplete", "Autocomplete email"
  param :email, String, "Email to autocomplete (will match only xxx@)", :required => true
  def create
    emails = User.where("email like '#{@email}@%'").map(&:email)
    if emails.size > 0
      render :json => { :emails => emails }
    else
      head :not_found
    end
  end
  
  private
  
  def process_params
    @email = params[:email]
    head :unprocessable_entity and return unless @email
    @email = @email.gsub(/@.*$/, "")
  end

end
