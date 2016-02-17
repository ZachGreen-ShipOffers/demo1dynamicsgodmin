class Client::Channel < ActiveRecord::Base
  belongs_to :client_company
  belongs_to :ship_station_store
  has_many :client_orders, class_name: 'Client::Order', foreign_key: :client_channel_id

end
