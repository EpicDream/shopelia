class Georges::DevicesDatatable
  delegate :params, :h, :link_to, :button_to, :time_ago_in_words, :number_with_delimiter, :admin_georges_device_messages_path, to: :@view

  def initialize(view)
    @view = view
    @filter_answer = case params[:pending_answer].to_i
    when 0 then [true, false]
    when 1 then [true]
    when 2 then [false]
    end
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: devices.count,
      iTotalDisplayRecords: devices.total_entries,
      aaData: data
    }
  end

  private

  def data
    devices.map do |device|
      last_message = device.messages.order("created_at desc").first
      [
        device.id,
        number_with_delimiter(device.events.clicks.count),
        number_with_delimiter(device.messages.count),
        "<span style='color:#{device.pending_answer ? 'red' : 'black'}'>#{last_message.content}</span>",
        "il y a " + time_ago_in_words(last_message.created_at),
        "<button type=\"button\" class=\"btn btn-info\" data-url=\"#{admin_georges_device_messages_path(device)}\" style=\"visibility:hidden\">View conversation</button>"
      ]
    end
  end

  def devices
    @devices ||= fetch_devices
  end

  def fetch_devices
    Device.joins(:messages).where(pending_answer:@filter_answer).uniq.order("updated_at desc").page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end