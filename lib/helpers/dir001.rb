module DynamicsHelper

  class Dir001 < ShipmentHelper
    @@allowed_skus =  %w(
    137-RASP-109
    117-GCBE-112
    116-GAR-116
    115-FSKLN-113
    181-MCLNSE-122
    122-KRL30-111
    141-TSTBLACK-111
    168-BRNBSTR-115
    154-PAINR-105
    120-JNT-106
    114-FISHOIL-105
    172-LIFETABS-105
    )


    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order,items,item_count)
      'BOX'
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
        end
      end
      return rslt
    end
  end
end
