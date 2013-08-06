class IncidentsDatatable
  delegate :params, :h, :link_to, :button_to, :time_ago_in_words, :incident_severity_to_html, :admin_incident_path, :truncate, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Incident.where(processed:false).count,
      iTotalDisplayRecords: incidents.total_entries,
      aaData: data
    }
  end

  private

  def data
    incidents.map do |incident|
      if incident.resource_type == 'Product'
        res_url = Product.find(incident.resource_id).try(:url)
        resource = res_url.blank? ? "" : link_to(truncate(res_url, :length => 50), res_url)
      elsif incident.resource_type == 'Merchant'
        resource = Merchant.find(incident.resource_id).name
      end
      [
        incident.issue,
        incident_severity_to_html(incident.severity),
        incident.description,
        time_ago_in_words(incident.created_at),
        resource,
        "<button type=\"button\" class=\"btn btn-danger\" data-loading-text=\"Please wait...\" data-update-url=\"#{admin_incident_path(incident)}\" style=\"visibility:hidden\">Mark as processed</button>"
      ]
    end
  end

  def incidents
    @incidents ||= fetch_incidents
  end

  def fetch_incidents
    incidents = Incident.where(processed:false).order("#{sort_column} #{sort_direction}")
    incidents = incidents.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("description like :search or issue like :search", search: "%#{params[:sSearch]}%")
    end
    incidents
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end
