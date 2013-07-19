class CreateProductMasters < ActiveRecord::Migration
  def change
    create_table :product_masters do |t|

      t.timestamps
    end
  end
end
