class Client::OrderItem < ActiveRecord::Base
  belongs_to :client_order, class_name: 'Client::Order', foreign_key: 'client_order_id'

  validates :sku, presence: true
  validate :sku_is_real_sku

  def sku_is_real_sku
    s = Client::Sku.where sku: sku
    if s.count == 0
      errors.add(:sku, "#{sku} is not in the system")
    end
  end
end
