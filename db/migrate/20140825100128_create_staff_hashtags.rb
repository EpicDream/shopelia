class CreateStaffHashtags < ActiveRecord::Migration
  def change
    create_table :staff_hashtags, :force => true do |t|
      t.string :name_fr
      t.string :name_en
      t.string :category
      t.boolean :visible, default:false
      t.timestamps
    end
  end
end