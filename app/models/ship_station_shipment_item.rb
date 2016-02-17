class ShipStationShipmentItem < ActiveRecord::Base
  belongs_to :shipment, class_name: 'ShipStationShipment', foreign_key: 'ship_station_shipment_id', inverse_of: :shipment_itemsexi
end
