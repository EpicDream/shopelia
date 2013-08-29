class Admin::IncidentsController < Admin::AdminController

  def index
    respond_to do |format|
      format.html
      format.json { render json: IncidentsDatatable.new(view_context) }
    end
  end

  def update
    @incident = Incident.find(params[:id])
    @incident.update_attribute :processed, true

    respond_to do |format|
      format.html { redirect_to admin_incidents_url }
      format.js { }
    end
  end  
end
