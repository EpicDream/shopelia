class DomainConstraints

  def initialize(subdomain)
    @subdomain = subdomain
  end

  def matches?(request)
    request.original_url.include?(@subdomain)
  end
end