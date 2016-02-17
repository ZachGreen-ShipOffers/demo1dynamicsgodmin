class ShipOffers::Sku < ActiveRecord::Base
  self.inheritance_column = :sku_kind
  self.abstract_class = true
  self.table_name = 'ship_offers_skus'
end
