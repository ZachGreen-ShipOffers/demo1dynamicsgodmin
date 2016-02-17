module DynamicsHelper

  class Oce001 < ShipmentHelper
    @@allowed_skus =  %w(
101-BLPR-103
101-BLPR-104
102-BLSG-104
168-BRNBSTR-120
120-JNT-103
120-JNT-111
122-KRL30-102
134-PROB30-102
129-OBSEA-101
154-PAINR-102
122-KRL30-121
134-PROB30-119

)
    def mapsku(the_order,sku,quantity)
      if sku == '129-OBSEA-102' || sku == '121-OBSEA-101' || sku == '124-OBSEA-101' || sku == '129-OBSEA' || sku == '121-OBSEA'
        sku = '129-OBSEA-101'
      end
      if sku == '134-PROBO30-119'
        sku = '134-PROB30-119'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.ship_station_order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order,items,item_count)
      if item_count <= 6
        return 'BAG'
      else
        return 'BOX'
      end
    end

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
