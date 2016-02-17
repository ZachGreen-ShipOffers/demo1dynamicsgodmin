module DynamicsHelper
  class Eqq001 < ShipmentHelper
    @@allowed_skus =  %w(116-GAR-107 115-FSKLN-103 215-USKID-101 181-MCLNSE-104).freeze

    def mapsku(the_order,sku,quantity)
      #sku = the_item.sku
      #qty = the_item.quantity
      if sku == '215-USKID-100'
        sku = '215-USKID-101'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      return 'BAG'
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
          rslt = 'SHIP-STD-06'
        elsif item_count >= 6
          rslt = 'SHIP-STD-10'
        end
      end
      return rslt
    end


  end
end
