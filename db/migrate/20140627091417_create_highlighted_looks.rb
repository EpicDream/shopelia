class CreateHighlightedLooks < ActiveRecord::Migration
  def change
    create_table :highlighted_looks, :force => true do |t|
      t.references :look
      t.references :hashtag
      t.timestamps
    end
  end
end