module Admin::LooksHelper
  def highlighted_brands html, brands
    html = strip_tags(html)
    matches = []
    brands.each_slice(1) do |slice|
      regexp = Regexp.new(slice.join("|"), true)
      matches += html.scan(regexp)
    end
    matches.flatten.uniq.compact.each do |brand|
      html =~ /(^|\W)(#{brand})(\W|$)/i
      html.gsub!($2, "<span class='highlight'>#{brand}</span>") if $2
    end
    html
  end
end
