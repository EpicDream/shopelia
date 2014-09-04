class AddMixpanelFlagToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :mixpanel, :boolean, default:false
  end
end