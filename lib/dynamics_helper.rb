module DynamicsHelper

  class ShipmentHelper


    def self.getClientFromCode(client_code)
      require_relative('./helpers/'+client_code.downcase+'.rb')
      return eval("DynamicsHelper::#{client_code.capitalize}.new")
    end

    def price_level
      return self.class.to_s.split('::').last.upcase
    end

    # @type [ShipStation::OrderItem] the_item
    def mapsku(the_order,sku,quantity)
      return {:sku=>sku,:quantity=>quantity}
    end

    # @type [ShipStation::Shipment] the_order
    # @type [ShipStation::OrderItem] the_item
    def packtype(the_order,items,item_count)
      return (item_count <= 6 ) ? 'BAG' : 'BOX'
    end

    # @type [ShipStation::Shipment] the_order
    # @type [Integer] item_count
    def shiptype(the_order,items,item_count)
      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        if item_count == 1
          rslt = 'SHIP-STD-01'
        elsif item_count == 2
          rslt = 'SHIP-STD-02'
        elsif item_count == 3
          rslt = 'SHIP-STD-03'
        elsif item_count == 4
          rslt = 'SHIP-STD-04'
        elsif item_count == 5
          rslt = 'SHIP-STD-06'
        elsif item_count >= 6 && item_count <= 9
          rslt = 'SHIP-STD-09'
        else
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end

  end

end
