class DevelopersDatatable
  delegate :params, :h, :link_to, :button_to, :time_ago_in_words, :admin_user_path, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Developer.count,
      iTotalDisplayRecords: developers.total_entries,
      aaData: data
    }
  end

  private

  def data
    developers.map do |developer|
      [
        developer.name,
        "<tt>#{developer.api_key}</tt>",
        developer.events.count,
        developer.orders.count,
        developer.users.count,
        developer.cart_items.count
      ]
    end
  end

  def developers
    @developers ||= fetch_developers
  end

  def fetch_developers
    developers = Developer.order("#{sort_column} #{sort_direction}")
    developers = developers.page(page).per_page(per_page)
    if params[:sSearch].present?
      developers = developers.where("name like :search", search: "%#{params[:sSearch]}%")
    end
    developers
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
