class ShipStationOrderService
  include Godmin::Resources::ResourceService

  attrs_for_index :order_number, :order_date, :order_status, :email, :carrier_code, :service_code, :package_code, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :residential, :address_verified, :ship_date
  attrs_for_show :order_number, :order_date, :order_status, :email, :carrier_code, :service_code, :package_code, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :residential, :address_verified, :ship_date
  attrs_for_form :order_number, :order_date, :order_status, :email, :carrier_code, :service_code, :package_code, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :residential, :address_verified, :ship_date
end
