class ShipStationStore < ActiveRecord::Base
  belongs_to :client, class_name: 'ClientCompany', foreign_key: 'client_company_id'
  has_many :orders, class_name: 'ShipStationOrder', foreign_key: 'ship_station_store_id', inverse_of: :store
  #has_many :shipments, class_name: 'ShipStationShipment', foreign_key: 'ship_station_store_id', inverse_of: :store
  has_many :shipments, through: :orders
  has_many :returns, class_name: 'ClientShipmentReturn', foreign_key: 'ship_station_store_id', inverse_of: :store

  def title
     self.store_name
  end

end
