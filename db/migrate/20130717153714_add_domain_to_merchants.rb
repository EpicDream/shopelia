class AddDomainToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :domain, :string
  end
end
