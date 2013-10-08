class Merchants::EventsDatatable
  delegate :params, :h, :event_action_to_html, :raw, to: :@view

  def initialize(view, merchant)
    @view = view
    @merchant = merchant
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
    @merchant.events
  end

  def data
    events.map do |event|
      [
        event_action_to_html(event.action),
        event.tracker,
        event.product.try(:name),
        event.created_at.to_s(:long)
      ]
    end
  end

  def events
    @events ||= fetch_events
  end

  def fetch_events
    events = event_req.order("created_at desc").page(page).per_page(per_page)
    if params[:sSearch].present?
      events = events.where("tracker like :search", search: "%#{params[:sSearch]}%")
    end
    events
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end