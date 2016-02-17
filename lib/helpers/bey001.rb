module DynamicsHelper
  class Bey001 < ShipmentHelper
    @@allowed_skus =  %w(

      102-BLSG-109
181-MCLNSE-107
117-GCBE-102
118-HGASPRAY-101
114-FISHOIL-101
137-RASP-102
141-TSTBLACK-101
181-MCLNSE-108
122-KRL30-106
148-VISSUPPORT-103

    ).freeze

    def mapsku(the_order,sku,quantity)
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
