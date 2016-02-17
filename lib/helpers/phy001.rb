module DynamicsHelper
  class Phy001 < ShipmentHelper
    @@allowed_skus =  %w(
      112-COQ10-102
      210-STRTCHSIL-109
      132-PHYT-120
      140-THYRO-105
      116-GAR-137
181-MCLNSE-142
134-PROB30-127
    ).freeze

    def mapsku(the_order,sku,quantity)

      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      rslt = 'BOX'
      return rslt
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
          elsif item_count >= 4 && item_count <= 9
            rslt = 'SHIP-STD-05'
          else
            rslt = 'SHIP-STD-11'
          end
        end
        return rslt
    end


  end
end
