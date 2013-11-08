class OrdersDatatable
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, :truncate, :admin_order_path, :order_state_to_html, :admin_user_path, :admin_order_path, to: :@view

  def initialize(view, filters = {})
    @view = view
    @filters = filters
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: orders.count,
      iTotalDisplayRecords: orders.total_entries,
      aaData: data
    }
  end

  private

  def data
    orders.map do |order|
      product = order.order_items.first.product
      [
        order_state_to_html(order.state_name),
        link_to(product.nil? ? "-" : product.name, admin_order_path(order)),
        order.merchant.name,
        number_to_currency(order.state == :completed ? order.billed_price_total : order.expected_price_total),
        link_to(order.user.name, admin_user_path(order.user)),
        order.created_at.strftime("%d/%m/%Y"),
        order.message,
        order.error_code,
        order.state_name == "pending_agent" ? "<button type=\"button\" class=\"btn btn-success\" data-uuid=\"#{order.uuid}\" style=\"visibility:hidden\">Kanaveral</button> <button type=\"button\" class=\"btn btn-warning btn-modal\" data-url=\"#{admin_order_path(order)}\" data-state=\"retry\" style=\"visibility:hidden\">Vulcain</button> <button type=\"button\" class=\"btn btn-danger btn-modal\" data-url=\"#{admin_order_path(order)}\" data-state=\"cancel\" style=\"visibility:hidden\">Cancel</button>" : ""
      ]
    end
  end

  def orders
    @orders ||= fetch_orders
  end

  def fetch_orders
    orders = Order.where("created_at>=? and created_at<=?", @filters[:date_start], @filters[:date_end]).where(state_name:@filters[:state]).order("#{sort_column} #{sort_direction}")
    orders = orders.page(page).per_page(per_page)
    orders
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[updated_at state_name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end
