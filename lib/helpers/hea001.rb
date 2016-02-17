module DynamicsHelper

  class Hea001 < ShipmentHelper

    @@allowed_skus = %w(
    101-BLPR-107
    114-FISHOIL-113
    134-PROB30-126
    102-BLSG-113
    )

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end



    # these are not real commands
    def packtype(the_order,items,item_count)
      return 'BAG'
    end


    def shiptype(the_order,items,item_count)
      rslt = ''
      if the_order.country != 'US'
        rslt = 'SHIP-INT-01'
      end
      case item_count
      when 1
        rslt = 'SHIP-STD-01'
      when 2
        rslt = 'SHIP-STD-02'
      when 3
        rslt = 'SHIP-STD-03'
      when 4
        rslt = 'SHIP-STD-04'
      when 5
        rslt = 'SHIP-STD-06'
      when 6
        rslt = 'SHIP-STD-08'
      when 7
        rslt = 'SHIP-STD-21'
      when 8
        rslt = 'SHIP-STD-22'
      when 9
        rslt = 'SHIP-STD-23'
      else
        rslt = 'SHIP-STD-11'
      end
      return rslt
    end

  end
end
