class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags, :force => true do |t|
      t.string :name
      t.timestamps
    end
  end
end