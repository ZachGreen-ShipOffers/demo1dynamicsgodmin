class ShipOffers::ShipType < ShipOffers::Sku
  self.table_name = 'ship_offers_ship_types'
  self.primary_key = 'id'
end