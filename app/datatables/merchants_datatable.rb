class MerchantsDatatable
  delegate :params, :h, :link_to, :image_tag, :number_to_currency, :number_with_delimiter, :conversion_rate, :semaphore, :raw, :admin_merchant_path, to: :@view

  def initialize(view, filters={})
    @view = view
    @filters = filters
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
        link_to(merchant.name, admin_merchant_path(merchant)),
        image_tag(merchant.logo.blank? ? "empty.png" : merchant.logo, class:"merchant-logo"),
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
    merchants = Merchant.where("vendor is #{@filters[:vulcain] == 1 ? "not" : ""} null").order(:id)
    merchants = merchants.where("name like :search or vendor like :search or url like :search", search: "%#{params[:sSearch]}%") if params[:sSearch].present?
    merchants.page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
