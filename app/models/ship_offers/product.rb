class ShipOffers::Product < ShipOffers::Sku
  self.table_name = 'ship_offers_products'
  self.primary_key = 'id'

  def client_products
    Client::Product.where(ship_offers_product_id: self.id)
  end
end
