class OrdersDatatable
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :time_ago_in_words, :truncate, to: :@view

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
        link_to(image_tag(order.order_items.first.product.image_url, style:"max-width:100px;max-height:40px"), "https://vulcain.shopelia.fr:444/admin/logs/#{order.uuid}"),
        image_tag(order.merchant.logo, style:"max-width:100px;max-height:40px"),
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
