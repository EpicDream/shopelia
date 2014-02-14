class AddLangIsoCodeToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :lang_iso, :string, default:'en-GB'
  end
end