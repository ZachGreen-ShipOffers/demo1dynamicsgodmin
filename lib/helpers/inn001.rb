module DynamicsHelper
  class Inn001 < ShipmentHelper
    @@allowed_skus =  %w(143-VP30-101 149-VTABS-101).freeze

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(the_order,items,item_count)
      has_rizer = false
      rslt = 'BOX'
      items.each do |i|
        if i[:sku] == '149-VTABS-101'
          has_rizer = true
          break
        end
      end
      if !has_rizer
        if item_count < 6
          rslt = 'BAG'
        end
      end
      return rslt
    end

    def shiptype(the_order, items, item_count)

      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        if item_count >= 1 && item_count <= 5

          rslt = 'SHIP-STD-17'
        elsif item_count >= 6
          rslt = 'SHIP-STD-10'
        end
      end
      return rslt
    end


  end
end
