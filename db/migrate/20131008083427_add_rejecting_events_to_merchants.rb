class AddRejectingEventsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :rejecting_events, :boolean, :default => false
    remove_column :merchants, :allow_iframe
  end
end
