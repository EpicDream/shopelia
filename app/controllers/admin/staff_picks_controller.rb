class Admin::StaffPicksController < Admin::AdminController
  
  def index
    @looks = Look.where(staff_pick:true)
    @flinkers = Flinker.staff_pick
    @hashtags = Hashtag.highlighted.includes(:looks)
  end
  
end
