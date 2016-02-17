module DynamicsHelper
  class Ben001 < ShipmentHelper
    @@allowed_skus =  %w(

     116-GAR-123
    115-FSKLN-104
    116-GAR-101
    117-GCBE-101
    137-RASP-101
    165-YACROOT-101
    132-PHYT-118
    292-BIOTIN-101

    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku.strip.downcase == 'raspberry ketone'
        sku = '137-RASP-101'
      elsif sku.strip.downcase == 'forskolin' || sku.strip.downcase == '1 forskolin'
        sku = '115-FSKLN-104'
      elsif sku.strip.downcase == 'garcinia cambogia'
        sku = '116-GAR-101'
      elsif sku.strip.downcase == 'green coffee'
        sku = '117-GCBE-101'
      elsif sku.strip.downcase == 'phytoceramides'
        sku = '132-PHYT-118'
      elsif sku == 'chia seeds'
        sku = '116-GAR-123'
      elsif sku.strip.downcase == 'yacon'
        sku = '165-YACROOT-101'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)

        rslt = 'BAG'
#      if somecheck
#        rslt = 'BOX'
#      end
      return rslt
    end

    def shiptype(the_order, items, item_count)
        items.each do |i|
          if i['sku'] = '292-BIOTIN-101'
            return 'SHIP-STD-01'
          end
        end
        return nil
    end


  end
end
