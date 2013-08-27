class MerchantsDatatable
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :number_with_delimiter, :conversion_rate, :semaphore, :raw, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: merchants.count,
      iTotalDisplayRecords: merchants.total_entries,
      aaData: data
    }
  end

  private

  def data
    merchants.map do |merchant|
      views = merchant.events.views.count
      clicks = merchant.events.clicks.count
      orders = merchant.orders.completed.count
      [
        merchant.id,
        link_to(merchant.name, merchant.url),
        image_tag(merchant.logo, class:"merchant-logo"),
        views,
        raw("#{number_with_delimiter(clicks)} <div class='rate'>#{conversion_rate(clicks, views)}</div>"),
        raw("#{number_with_delimiter(orders)} <div class='rate'>#{conversion_rate(orders, clicks)}</div>"),
        number_to_currency(merchant.orders.completed.sum(:billed_price_total)),
        merchant.vendor,
        semaphore(merchant.vulcain_test_pass)
      ]
    end
  end

  def merchants
    @merchants ||= fetch_merchants
  end

  def fetch_merchants
    merchants = Merchant.order(:id).page(page).per_page(per_page)
    if params[:sSearch].present?
      merchants = merchants.where("name like :search or vendor like :search or url like :search", search: "%#{params[:sSearch]}%")
    end
    merchants
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
