module Admin::LooksHelper
  def highlighted_brands html, brands
    html = strip_tags(html)
    matches = []
    brands.each_slice(100) do |slice|
      regexp = Regexp.new(slice.join("|"), true)
      matches += html.scan(regexp)
    end
    matches.flatten.uniq.compact.each do |brand|
      html.gsub!(/(\W|^)#{brand}(\W|$)/i, "<span class='highlight'>#{brand}</span>")
    end
    html
end
end
