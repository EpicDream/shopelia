class AddDeviceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :device_id, :integer
    Event.all.each do |event|
      device = Device.fetch(event.visitor, event.user_agent)
      event.update_column "device_id", device.id
    end
    remove_column :events, :visitor
    remove_column :events, :user_agent
  end
end
