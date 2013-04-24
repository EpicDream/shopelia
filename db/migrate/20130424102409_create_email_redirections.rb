class CreateEmailRedirections < ActiveRecord::Migration
  def change
    create_table :email_redirections do |t|
      t.string :user_name
      t.string :destination

      t.timestamps
    end
  end
end
