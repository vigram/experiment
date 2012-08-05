class ProductsController < ApplicationController
	def index
		@products = Product.first
	end
end
