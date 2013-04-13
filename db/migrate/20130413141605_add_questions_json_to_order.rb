class AddQuestionsJsonToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :questions_json, :string
  end
end
