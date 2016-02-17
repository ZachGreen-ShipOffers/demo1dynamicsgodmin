module DynamicsHelper

  class Pur001 < ShipmentHelper
    @@allowed_skus =  %w(
190-ADVCMPNT-101
191-ARTHAM-101
192-ARTHPM-101
134-PROB30-104
168-BRNBSTR-112
120-JNT-110
122-KRL30-109
115-FSKLN-110
)
    def mapsku(the_order,sku,quantity)
      if sku == '#190-ADVCMPNT-101'
        sku = '190-ADVCMPNT-101'
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
        rslt = 'SHIP-INT-01'
      else
        if item_count >= 1 && item_count <= 3
          rslt = 'SHIP-STD-18'
        elsif item_count >=4 && item_count <= 6
          rslt = 'SHIP-STD-19'
        elsif item_count >=7 && item_count <= 11
          rslt = 'SHIP-STD-12'
        elsif item_count >= 12 && item_count <= 14
          rslt = 'SHIP-STD-13'
        elsif item_count >= 15 && item_count <= 17
          rslt = 'SHIP-STD-14'
        elsif item_count >= 18 && item_count <= 29
          rslt = 'SHIP-STD-15'
        else
          rslt = 'SHIP-STD-16'
        end
      end
      return rslt
    end

  end

end
