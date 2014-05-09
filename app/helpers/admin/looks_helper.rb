module Admin::LooksHelper
  def highlighted_brands html, brands
    regexp = Regexp.new(brands.join("|"), true)
    matches = html.scan(regexp).uniq
    matches.each do |brand|
      html.gsub!(/#{brand}/i, "<span class='highlight'>#{brand}</span>")
    end
    html
  end
end