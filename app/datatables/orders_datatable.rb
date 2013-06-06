class OrdersDatatable
  delegate :params, :h, :link_to, :number_to_currency, :time_ago_in_words, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Order.count,
      iTotalDisplayRecords: orders.total_entries,
      aaData: data
    }
  end

  private

  def data
    orders.map do |order|
      [
        link_to(order.order_items.first.product.name, "https://vulcain.shopelia.fr:444/admin/logs/#{order.uuid}"),
        number_to_currency(order.expected_price_total),
        h(order.user.name),
        time_ago_in_words(order.updated_at),
        order.error_code
      ]
    end
  end

  def orders
    @orders ||= fetch_orders
  end

  def fetch_orders
    orders = Order.where(state_name:params[:state]).order("#{sort_column} #{sort_direction}")
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
