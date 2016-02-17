class Client::Sku < ActiveRecord::Base
  has_many :maps, :class_name=>'Client::ProductSkuMap', :foreign_key => :client_sku_id
  has_many :products, :through => :maps
end
