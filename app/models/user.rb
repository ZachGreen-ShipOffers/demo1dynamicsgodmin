class User < ActiveRecord::Base

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  has_and_belongs_to_many :clients,
                          class_name: 'ClientCompany',
                          inverse_of: :users,
                          join_table: 'clients_users'

  has_many :stores, :through => :clients
  has_many :orders, :through => :stores
  has_many :returns, :through => :stores
  has_many :shipments, :through => :stores
  has_many :client_products, :through => :clients
  has_many :client_channels, through: :clients, class_name: 'Client::Channel'
  has_many :client_orders, class_name: 'Client::Order', through: :client_channels

  def manual_channel_id
    self.client_channels.where(client_channel_type_id: "96f72b78-fd43-4cde-94dc-6f31eb84aed7").first.id
  end
end
