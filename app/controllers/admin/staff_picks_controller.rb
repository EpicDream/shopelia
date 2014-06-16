class Admin::StaffPicksController < Admin::AdminController
  
  def index
    @looks = Look.where(staff_pick:true).order('flink_published_at desc')
    @flinkers = Flinker.staff_pick
    @hashtags = Hashtag.highlighted.includes(:looks)
  end
  
end
