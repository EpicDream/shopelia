class AddNewsletterToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :newsletter, :boolean, default:true
  end
end