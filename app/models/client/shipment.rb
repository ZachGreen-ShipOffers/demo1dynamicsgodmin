class Client::Shipment < ActiveRecord::Base
  has_many :client_order_shipments, class_name: 'Client::OrderShipment'
  has_many :orders, through: :client_order_shipments
end
