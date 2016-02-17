module DynamicsHelper
  class Pur002 < ShipmentHelper
    @@allowed_skus =  %w(
        1134-PROB30-117
        179-KIDNEY-106
        225-TRMRIC-101
        100-BCAA-105
        272-ADVPROB-101
        273-PREPRO-101
        274-PARATX-101
        275-BLFLSH-101
        281-DSPRAY-101
    ).freeze

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(the_order, items,item_count)
      return 'BAG'
    end

    def shiptype(the_order,items, item_count)

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
        elsif item_count >=6 && item_count <= 9
          rslt = 'SHIP-STD-09'
        elsif item_count >=10
          rslt = 'SHIP-STD-11'
        end
      end

      return rslt
    end


  end
end
