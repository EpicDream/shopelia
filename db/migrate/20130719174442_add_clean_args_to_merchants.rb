class AddCleanArgsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :should_clean_args, :boolean, :default => false
  end
end
