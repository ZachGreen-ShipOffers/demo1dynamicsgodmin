class Client::Product < ActiveRecord::Base
  has_many :maps, :class_name=>'Client::ProductSkuMap', :foreign_key => :client_product_id
  has_many :skus, :through => :maps, :foreign_key => :client_sku_id
  belongs_to :client, class_name: 'ClientCompany'

  def client_skus(id)
    sql =
    "SELECT
      client_skus.id,
      client_skus.sku,
      client_skus.description,
      client_product_sku_maps.quantity
    FROM
      client_products
    LEFT JOIN client_product_sku_maps ON client_products.id = client_product_sku_maps.client_product_id
    LEFT JOIN client_skus ON client_product_sku_maps.client_sku_id = client_skus.id
    WHERE
      client_products.id = '#{id}';"
    rslt = Client::Sku.find_by_sql(sql)
    rslt

  end
end
