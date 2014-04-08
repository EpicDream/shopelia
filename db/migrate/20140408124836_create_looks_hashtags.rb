class CreateLooksHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags_looks, :force => true do |t|
      t.references :look
      t.references :hashtag
    end
  end
end