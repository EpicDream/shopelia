class EventsDatatable
  delegate :params, :h, :conversion_rate, :number_with_delimiter, :raw, to: :@view

  def initialize(view, options = {})
    @view = view
    @options = options
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: event_req.count,
      iTotalDisplayRecords: events.total_entries,
      aaData: data
    }
  end

  private

  def event_req
    event_req = Event.where("created_at>=? and created_at<=?", @options[:date_start], @options[:date_end]).group([:developer_id,:tracker])
    event_req = event_req.send(:for_developer, @options[:developer]) unless @options[:developer].nil?
    event_req = event_req.send(:for_tracker, @options[:tracker]) unless @options[:tracker].blank?
    event_req
  end

  def data
    events.map do |event|
      developer = Developer.find(event.developer_id)
      clicks = Event.where("created_at>=? and created_at<=?", @options[:date_start], @options[:date_end]).where(developer_id:developer.id,tracker:event.tracker).clicks.count
      [
        developer.name,
        event.tracker,
        number_with_delimiter(event.count),
        raw("#{number_with_delimiter(clicks)} <div class='rate'>#{conversion_rate(clicks.to_i, event.count.to_i)}</div>")
      ]
    end
  end

  def events
    @events ||= fetch_events
  end

  def fetch_events
    event_req.select("count(*) as count,developer_id,tracker").order("count(*) desc").page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
