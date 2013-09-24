class VikingDatatable
  delegate :params, :h, :link_to, :time_ago_in_words, :truncate, :viking_failure_tags, :retry_admin_product_path, :mute_admin_product_path, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Product.where(viking_failure:true).where("updated_at > ?", 1.day.ago).count,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  private

  def data
    products.map do |product|
      [
        link_to(truncate(product.url, :length => 50), product.url),
        product.id,
        viking_failure_tags(product),
        time_ago_in_words(product.updated_at),
        "<button type=\"button\" class=\"btn btn-success\" data-loading-text=\"...\" data-retry-url=\"#{retry_admin_product_path(product)}\" style=\"visibility:hidden\">Retry</button> <button type=\"button\" class=\"btn btn-warning\" data-loading-text=\"...\" data-mute-url=\"#{mute_admin_product_path(product)}\" style=\"visibility:hidden\">Mute</button> <button type=\"button\" class=\"btn btn-danger\" data-loading-text=\"...\" data-mute-url=\"#{mute_admin_product_path(product)}\" style=\"visibility:hidden\">Reject</button> <button type=\"button\" class=\"btn btn-info\" data-url=\"#{product.url}\" style=\"visibility:hidden\">Ariane</button>"
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = Product.where(viking_failure:true).where("updated_at > ?", 1.day.ago).order("#{sort_column} #{sort_direction}")
    products = products.page(page).per_page(per_page)
    if params[:sSearch].present?
      products = products.where("url like :search or name like :search", search: "%#{params[:sSearch]}%")
    end
    products  
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end
