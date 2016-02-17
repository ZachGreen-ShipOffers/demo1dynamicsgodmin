class ShipStationOrder < ActiveRecord::Base
  belongs_to :store, class_name: 'ShipStationStore', foreign_key: 'ship_station_store_id', inverse_of: :orders
  has_many :returns, class_name: 'ClientShipmentReturn', foreign_key: 'ship_station_store_id'
  has_many :shipments, class_name: 'ShipStationShipment', foreign_key: 'ship_station_order_id', inverse_of: :ss_order

  scope :pending, -> { where("(order_status not in ('on_hold','cancelled','shipped'))")}
  scope :shipped, -> { where("(order_status = 'shipped')") }
  scope :onhold, -> { where("(order_status = 'on_hold')")}
  scope :cancelled, -> { where("(order_status = 'cancelled')")}

end