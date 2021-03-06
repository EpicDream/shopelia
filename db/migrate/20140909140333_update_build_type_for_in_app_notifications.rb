class UpdateBuildTypeForInAppNotifications < ActiveRecord::Migration
  def up
    execute("ALTER TABLE IN_APP_NOTIFICATIONS ALTER MIN_BUILD TYPE INTEGER USING MIN_BUILD::INT")
    execute("ALTER TABLE IN_APP_NOTIFICATIONS ALTER MAX_BUILD TYPE INTEGER USING MAX_BUILD::INT")
  end
  
  def down
    execute("ALTER TABLE IN_APP_NOTIFICATIONS ALTER MIN_BUILD TYPE VARCHAR USING MIN_BUILD::VARCHAR")
    execute("ALTER TABLE IN_APP_NOTIFICATIONS ALTER MAX_BUILD TYPE VARCHAR USING MAX_BUILD::VARCHAR")
  end
end