class FlinkersDatatable
  delegate :params, :h, :link_to, :image_tag, :number_with_delimiter, :raw, :admin_flinker_path, to: :@view

  def initialize(view, filters={})
    @view = view
    @filters = filters
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: flinkers.count,
      iTotalDisplayRecords: flinkers.total_entries,
      aaData: data
    }
  end

  private

  def data
    flinkers.map do |flinker|
      blog = Blog.find_by_flinker_id(flinker.id)
      [
        flinker.id,
        link_to(flinker.name || flinker.username || flinker.url || flinker.id, admin_flinker_path(flinker)),
        flinker.email,
        image_tag(flinker.avatar.blank? ? "empty.png" : flinker.avatar.url(:thumb), class:"avatar"),
        number_with_delimiter(flinker.looks_count),
        number_with_delimiter(flinker.follows_count),
        number_with_delimiter(flinker.likes_count),
        flinker.url,
        flinker.is_publisher? ? "Yes" : "No",
        flinker.staff_pick? ? "Yes" : "No",
        flinker.display_order,
        "<button type=\"button\" class=\"btn btn-danger\" data-destroy-url=\"#{admin_flinker_path(flinker)}\" data-username=\"#{flinker.username}\" style=\"visibility:hidden\">Delete</button>"
      ]
    end
  end

  def flinkers
    @flinkers ||= fetch_flinkers
  end

  def fetch_flinkers
    flinkers = Flinker.rank(:display_order)
    flinkers = flinkers.where("is_publisher=?", @filters[:publisher] == 'yes') if @filters[:publisher].present?
    flinkers = flinkers.where("staff_pick = ?", @filters[:staff_pick] == 'yes') unless @filters[:staff_pick].blank?
    flinkers = flinkers.of_country(@filters[:country]) unless @filters[:country].blank?
    flinkers = flinkers.universals if @filters[:universal] && @filters[:universal] == 'yes'
    flinkers = flinkers.where("name like :search or url like :search", search: "%#{params[:sSearch]}%") if params[:sSearch].present?
    flinkers.page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
