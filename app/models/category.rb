class Category < ActiveRecord::Base
	has_many :products

	after_create :do_this

	def do_this
		Product.create(:name => 'testing')
	end
end
