class CreateHashtagsThemes < ActiveRecord::Migration
  def change
    create_table :hashtags_themes, :force => true do |t|
      t.references :theme
      t.references :hashtag
    end
  end
end