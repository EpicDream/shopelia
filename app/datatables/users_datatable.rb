class UsersDatatable
  delegate :params, :h, :link_to, :button_to, :time_ago_in_words, :admin_user_path, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.total_entries,
      aaData: data
    }
  end

  private

  def data
    users.map do |user|
      [
        link_to(user.email, admin_user_path(user)),
        user.name,
        time_ago_in_words(user.created_at),
        user.orders.completed.count,
        user.cart_items.count,
        "<button type=\"button\" class=\"btn btn-danger\" data-destroy-url=\"#{admin_user_path(user)}\" data-username=\"#{user.name}\" style=\"visibility:hidden\">Destroy the user</button>"
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    users = User.order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("last_name like :search or first_name like :search or email like :search", search: "%#{params[:sSearch]}%")
    end
    users
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
