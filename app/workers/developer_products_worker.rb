class DeveloperProductsWorker
  include Sidekiq::Worker

  def perform hash
    developer = Developer.find(hash["developer_id"])
    (hash["urls"] || "").split(/\n/).each do |url|
      next if url !~ /^http/
      p = Product.fetch(url)
      developer.products << p unless developer.products.include?(p)
      Event.create(
        :product_id => p.id,
        :action => Event::REQUEST,
        :developer_id => developer.id)
    end
  end
end