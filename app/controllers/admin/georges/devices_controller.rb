class Admin::Georges::DevicesController < Admin::AdminController
  def index
    @devices = Device.where(pending_answer:true).uniq
  end
end
