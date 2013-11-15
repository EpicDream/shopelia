class AddJsonDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :json_description, :text
  end
end