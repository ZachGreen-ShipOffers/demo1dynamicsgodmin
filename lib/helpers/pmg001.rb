module DynamicsHelper

  class Pmg001 < ShipmentHelper
    @@allowed_skus =  %w(
181-MCLNSE-106
116-GAR-106
117-GCBE-110
137-RASP-104
119-HYDROEYES-106
132-PHYT-117

)
    def mapsku(the_order,sku,quantity)
      if sku == '165-YACROOT-107'
        return {:sku=>'NULL',:quantity=>0}
      elsif sku == 'Pure Green Coffee Refill Package' || sku == 'Pure Green Coffee Refill Package (Vs2)' || sku.start_with?('Pure Green Coffee Refill Package')
        sku = '117-GCBE-110'
      elsif sku.start_with?('Pure Garcinia Refill Package') || sku == '16-GAR-106'
        sku = '116-GAR-106'
      elsif sku.start_with?('Pure Ketone Plus Refill Package')
        sku = '137-RASP-104'
      elsif sku.start_with?('111-COLN')
        sku = '181-MCLNSE-106'
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

    def packtype(the_order,items,item_count)
      if item_count <= 6
        return 'BAG'
      else
        return 'BOX'
      end
    end

    def shiptype(the_order,items,item_count)
      if the_order.country_code != 'US'
        if the_order.country_code == 'CA'
          rslt = 'SHIP-INT-06'
        elsif the_order.country_code == 'AU'
          rslt = 'SHIP-INT-07'
        else
          rslt = 'SHIP-INT-01'
        end
      else
        if item_count == 1
          rslt = 'SHIP-STD-01'
        elsif item_count >=2
          rslt = 'SHIP-STD-20'
        end
      end
      return rslt
    end

  end

end
