class Admin::DevicesController < Admin::AdminController

  def show
    @device = Device.find(params[:id])
    views = @device.events.views.count
    clicks = @device.events.clicks.count
    @stats = [
      { name:"views", value:views, type: :number },
      { name:"clicks", value:clicks, type: :number },
      { name:"messages", value:@device.messages.count, type: :number }
    ]

    respond_to do |format|
      format.html
      format.json { render json: Devices::EventsDatatable.new(view_context, @device) }
    end
  end
end