class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters, :force => true do |t|
      t.string :header_img_url
      t.string :footer_img_url
      t.string :favorites_ids
      t.string :look_uuid
      t.timestamps
    end
  end
end