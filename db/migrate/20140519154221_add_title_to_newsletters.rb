class AddTitleToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :subject_fr, :string
    add_column :newsletters, :subject_en, :string
  end
end