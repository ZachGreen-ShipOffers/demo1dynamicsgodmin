module DynamicsHelper
  class Fit001 < ShipmentHelper
    @@allowed_skus =  %w(

    100-BCAA-102
131-PHEN-101
141-TSTBLACK-109

    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == 'TIB'
        sku = '141-TSTBLACK-109'
      end
      if !@@allowed_skus.include?(sku)
        @@allowed_skus.each do |s|
          if sku == s[/(\d+\-\w+)/]
            sku = s
            break
          end
        end
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
        rslt = 'BAG'
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
