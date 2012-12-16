class Product < ActiveRecord::Base
	belongs_to :category
	validates :name, :presence => true
	#validates :category_id, :inclusion => {:in => [1..100], :message => "Exceeding the category limit"}
end
