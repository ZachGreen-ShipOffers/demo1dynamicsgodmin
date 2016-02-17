module DynamicsHelper
  class Onl001 < ShipmentHelper
    @@allowed_skus =  %w(
      116-GAR-125
106-BRS-106
107-BRSCREAM-105
108-BRSTAB-102
106-BRS-101
107-BRSCREAM-101
143-VP30-103
149-VTABS-112
125-LQRX-105
110-COL-103
130-PER-103
125-LQRX-106
149-VTABS-113
146-VPRXBLUE-103
150-ZNIC-101
211-ZNICP-101
137-RASP-115
    ).freeze

    @@box_only = %w(
      107-BRSCREAM-105
      108-BRSTAB-102
      107-BRSCREAM-101
      149-VTABS-113
      149-VTABS-112
      149-VTABS
      107-BRSCREAM
      108-BRSTAB
    )

    def mapsku(the_order,sku,quantity)
      if sku == '150-PATCH'
        sku = '211-ZNICP-101'
      elsif sku == 'PER'
        sku = '130-PER-103'
      elsif sku == 'VPRX' || sku == 'VPLUS'
        sku = '146-VPRXBLUE-103'
      elsif sku == 'ZNPATCH'
        sku = '150-ZNIC-101'
      elsif sku == 'BRS' || sku == 'BUST'
        sku = '106-BRS-106'
      elsif sku == 'BRSCREAM'
        sku = '107-BRSCREAM-105'
      elsif sku == 'CLIMINAX'
        sku = '143-VP30-103'
      elsif sku == 'ZNPILLS1'
        sku = '211-ZNICP-101'
      elsif sku == 'CREAM'
        sku = '107-BRSCREAM-101'
      elsif sku == 'SZPRO-RTL' || sku =='SIZEPRO1'
        sku = '149-VTABS-113'
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
      if item_count > 6
        rslt = 'BOX'
      else
        items.each do |item|
          if @@box_only.include?(item[:sku])
            rslt = 'BOX'
            break
          end
        end
      end
      return rslt
    end

    def shiptype(the_order, items, item_count)

      if the_order.carrier_code == 'fedex' && the_order.service_code == 'fedex_2day'
        rslt = 'SHIP-EXP-01'
      elsif the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        if item_count >= 1 && item_count <= 5
          rslt = 'SHIP-STD-17'
        elsif item_count >=6
          rslt = 'SHIP-STD-10'
        end
      end
      return rslt
    end


  end
end
