class AddAllowIframeToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :allow_iframe, :boolean, :default => true
  end
end
