module DynamicsHelper
  class Ure001 < ShipmentHelper
    @@allowed_skus =  %w(
        168-BRNBSTR-108
        117-GCBE-104
        127-MVIT-104
        142-TSTWHITE-101
        136-PRSTSUP-102
    ).freeze

    def mapsku(the_order,sku,quantity)

        if sku == 'GCB2'
          sku = '117-GCBE-104'
          quantity = quantity * 2
        elsif sku == 'GCB3'
          sku = '117-GCBE-104'
          quantity = quantity * 2
        elsif sku == 'UTB1'
          sku = '142-TSTWHITE-101'
        elsif sku == 'UTB2'
          sku = '142-TSTWHITE-101'
          quantity = quantity * 2
        elsif sku == 'UTB4'
          sku = '142-TSTWHITE-101'
          quantity = quantity * 4
        elsif sku == 'UTB5'
          sku = '142-TSTWHITE-101'
          quantity = quantity * 5
        elsif sku == 'UTB6'
          sku = '142-TSTWHITE-101'
          quantity = quantity * 6

        end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(the_order, items,item_count)
      if item_count < 6
        return 'BAG'
      else
        return 'BOX'
      end
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
