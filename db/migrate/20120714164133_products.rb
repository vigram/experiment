class Products < ActiveRecord::Migration
  def up
    create_table :products do |t|
      t.string :name
      t.text :description
 
      t.timestamps
    end
  end
 
  def down
    drop_table :products
  end
end