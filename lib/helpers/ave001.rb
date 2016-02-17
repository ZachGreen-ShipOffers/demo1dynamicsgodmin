
module DynamicsHelper


  class Ave001 < ShipmentHelper

    @@allowed_skus =%w(
      115-FSKLN-117
      116-GAR-121
      117-GCBE-130
      119-HYDROEYES-113
      210-STRTCHSIL-114
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
      if item_count <=10
        rslt = 'BAG'
      else
        rslt = 'BOX'
      end
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
        elsif item_count == 4
          rslt = 'SHIP-STD-04'
        elsif item_count == 5
          rslt = 'SHIP-STD-06'
        elsif item_count >= 6 && item_count <= 9
          rslt = 'SHIP-STD-09'
        elsif item_count >= 10
          rslt = 'SHIP-STD-11'
        else
          raise ArgumentError, "Bad Item Count. #{item_count} #{item_count.class}"
        end
      end
      return rslt
    end


  end
end
