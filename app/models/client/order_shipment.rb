class Client::OrderShipment < ActiveRecord::Base
  belongs_to :order, class_name: 'Client::Order'
  belongs_to :shipment, class_name: 'Client::Shipment'
end
