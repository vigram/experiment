class Category < ActiveRecord::Base
	has_many :products
	validates :name, :presence => true

	#after_create :do_this

	#def do_this
	#	Product.create!(:name => '')
	#end
end
