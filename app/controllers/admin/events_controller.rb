class Admin::EventsController < Admin::AdminController
  before_filter :prepare_graph_params, :only => :index
  
  def index
    respond_to do |format|
      format.html
      format.json { 
        if params[:graph].present?
          render json: render_chart
        else
          render json: EventsDatatable.new(view_context, {
            date_start:@date_start,
            date_end:@date_end,
            tracker:@tracker,
            developer:@developer
          }) 
        end
      }
    end
  end

  private

  def render_chart
    chart = []
    event_req = Event.where("created_at>=? and created_at<=?", @date_start, @date_end)
    event_req = event_req.send(:for_developer, @developer) unless @developer.nil?
    event_req = event_req.send(:for_tracker, @tracker) unless @tracker.blank?
    event_req.count(:group => ["date(created_at)",:action]).each do |data|
      if data[0][1] == Event::VIEW
        chart << { "date" => data[0][0], "view" => data[1] }
      elsif data[0][1] == Event::CLICK
        chart << { "date" => data[0][0], "click" => data[1] }
      end
    end
    chart.group_by{|h| h["date"]}.map{|k,v| v.inject(:merge)}
  end

  def prepare_graph_params
    @date_start = params[:date_start].blank? ? Event.order(:created_at).first.created_at : Date.parse(params[:date_start])
    @date_end = params[:date_end].blank? ? Event.order(:created_at).last.created_at : Date.parse(params[:date_end]) + 1.day
    @developer = Developer.find(params[:developer_id].to_i) unless params[:developer_id].blank? 
    @tracker = params[:tracker]
  end

end
