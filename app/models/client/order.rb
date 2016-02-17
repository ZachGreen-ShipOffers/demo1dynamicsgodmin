class Client::Order < ActiveRecord::Base
  enum status: {awaiting_fulfillment: 'awaiting_fulfillment', awaiting_shipment: 'awaiting_shipment', shipped: 'shipped', canceled: 'canceled',onhold: 'onhold', unverified: 'unverified'}
  has_many :client_order_shipments, class_name: 'Client::OrderShipment'
  has_many :shipments, through: :client_order_shipments
  has_many :client_order_items, class_name: 'Client::OrderItem', foreign_key: 'client_order_id', dependent: :destroy
  accepts_nested_attributes_for :client_order_items, allow_destroy: true
  belongs_to :client_channel, class_name: 'Client::Channel', foreign_key: :client_channel_id
  # belongs_to :client, class_name: 'ClientCompany'

  def clients
    ClientCompany.where(id: self.client_channel.client_company_id).first
  end
end
