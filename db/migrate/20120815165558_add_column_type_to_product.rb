class AddColumnTypeToProduct < ActiveRecord::Migration
  def change
  	 add_column :products, :type, :string
  end
end
