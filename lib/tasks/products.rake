namespace :flink do
  namespace :products do
    
    desc "Extract PureShopping products in a mongodb index"
    task :pure_shopping => :environment do
      require 'crawlers/pureshopping/pureshopping'
      PureShoppingProduct.delete_all
      Crawlers::Pureshopping.new.run
    end

  end
end