class Client::ProductSkuMap < ActiveRecord::Base
  belongs_to :product, :class_name => 'Client::Product', :foreign_key => :client_product_id
  belongs_to :sku, :class_name => 'Client::Sku', :foreign_key => :id

  def product_sku
    self.product.sku
  end

  def sku_sku
    self.sku_sku
  end

end
