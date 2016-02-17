class ShipStationShipment < ActiveRecord::Base

  has_one :store, :through => :ss_order
  belongs_to :ss_order, class_name: 'ShipStationOrder', foreign_key: 'ship_station_order_id', inverse_of: :shipments
  has_many :shipment_items, class_name: 'ShipStationShipmentItem', foreign_key: 'ship_station_shipment_id'

  UPS_TPL = 'http://wwwapps.ups.com/WebTracking/processRequest?HTMLVersion=5.0&Requester=NES&AgreeToTermsAndConditions=yes&loc=en_US&tracknum=%s'.freeze
  FEDEX_TPL = 'https://www.fedex.com/apps/fedextrack/?action=track&language=english&tracknumbers=%s'.freeze
  USPS_TPL = 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=%s'.freeze


  def self.carrier_tracking_link(carrier,tracking_number)
    if carrier == 'ups'
      UPS_TPL % tracking_number
    elsif carrier == 'fedex'
      FEDEX_TPL % tracking_number
    elsif carrier == 'stamps_com'
      USPS_TPL % tracking_number
    elsif carrier == 'express_1'
      USPS_TPL % tracking_number
    elsif carrier == 'endicia'
      USPS_TPL % tracking_number
    end
  end

  def tracking_link
    ShipStationShipment.carrier_tracking_link(carrier_code,tracking_number)
  end

  def country_code
    return self.country
  end

  def order_id
    return self.ship_station_order_id
  end

end
