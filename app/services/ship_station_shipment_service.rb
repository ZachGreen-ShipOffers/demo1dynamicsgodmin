class ShipStationShipmentService
  include Godmin::Resources::ResourceService

  attrs_for_index :order_number, :tracking_number, :carrier_code, :service_code, :package_code, :voided, :void_date, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :email, :ship_date
  attrs_for_show :order_number, :tracking_number, :carrier_code, :service_code, :package_code, :voided, :void_date, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :email, :ship_date
  attrs_for_form :order_number, :tracking_number, :carrier_code, :service_code, :package_code, :voided, :void_date, :name, :company, :street1, :street2, :street3, :city, :state, :postal_code, :country, :phone, :email, :ship_date
end
