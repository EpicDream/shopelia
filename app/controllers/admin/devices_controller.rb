class Admin::DevicesController < Admin::AdminController
  def index
    @devices = Device.joins(:messages).where("messages.pending_answer=?", true).uniq
  end
end
