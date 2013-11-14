class DropTableUrlMatchers < ActiveRecord::Migration
  def up
    drop_table :url_matchers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
