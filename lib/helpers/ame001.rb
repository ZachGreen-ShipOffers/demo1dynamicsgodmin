
module DynamicsHelper


  class Ame001 < ShipmentHelper

    @@allowed_skus =%w(
    179-KIDNEY-107
    181-MCLNSE-135
    122-KRL30-120
    226-CRALMA-101
    179-KIDNEY-108
    117-GCBE-129
    ).freeze

    def mapsku(the_order,sku,quantity)

      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      'BOX'
    end

    def shiptype(the_order, items, item_count)
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
        elsif item_count >= 5 && item_count <= 9
          rslt = 'SHIP-STD-07'
        else
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end


  end
end
