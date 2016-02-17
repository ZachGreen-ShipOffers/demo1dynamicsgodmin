module DynamicsHelper
  class Bbh001 < ShipmentHelper

    @@allowed_skus =%w(
    102-BLSG-112
    101-BLPR-106
    120-JNT-114
    115-FSKLN-121
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
        elsif item_count == 5
          rslt = 'SHIP-STD-07'
        elsif item_count == 6
          rslt = 'SHIP-STD-08'
        elsif item_count == 7
          rslt = 'SHIP-STD-21'
        elsif item_count == 8
          rslt = 'SHIP-STD-22'
        elsif item_count == 9
          rslt = 'SHIP-STD-23'
        else
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end


  end
end
