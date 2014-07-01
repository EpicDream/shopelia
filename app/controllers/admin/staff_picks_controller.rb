class Admin::StaffPicksController < Admin::AdminController
  
  def index
    @looks = Look.staff_picked.includes(:flinker).order('flink_published_at desc')
    @flinkers = Flinker.staff_pick.joins(:country).order('countries.iso asc')
    @hashtags = HighlightedLook.hashtags
  end
  
end
