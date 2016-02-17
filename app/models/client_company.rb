class ClientCompany < ActiveRecord::Base
  has_many :dynamics_infos
  has_many :stores, class_name: 'ShipStationStore'
  has_and_belongs_to_many :users,
                          class_name: 'User',
                          inverse_of: :clients,
                          join_table: 'clients_users'
  has_many :client_products, class_name: 'Client::Product'
  has_many :client_channels, class_name: 'Client::Channel'
  has_many :client_orders, class_name: 'Client::Order', through: :client_channels
  has_many :orders, through: :stores
  has_many :shipments, through: :stores
  has_many :returns, through: :stores
  has_many :notification_recipients, class_name: 'NotificationRecipient', autosave: true, dependent: :delete_all, foreign_key: 'client_company_id'

  scope :by_token, ->(tkn) { where('client_api_token(client_companies.uuid::text,client_companies.api_password::text,client_companies.api_secret::text) = ?',tkn) }

  accepts_nested_attributes_for :notification_recipients, allow_destroy: true

  validates :dyna_code,
              presence: true,
              uniqueness: true,
              format: { with: /\A[A-Z]{3,3}[0-9]{3,3}\z/, message: '3 alpha + 3 digits'}  ,
              strict: true

  # validates :company, presence: true, strict: true

  # def dyna_code=(val)
  #   begin
  #     @dyna_code = val.to_s.strip.upcase
  #   rescue ArgumentError
  #     nil
  #   end
  # end

end
