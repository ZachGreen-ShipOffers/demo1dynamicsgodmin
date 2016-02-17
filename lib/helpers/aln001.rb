
module DynamicsHelper


  class Aln001 < ShipmentHelper

    @@allowed_skus =  %w(

      117-GCBE-127
      116-GAR-127

    ).freeze

    def mapsku(the_order,sku,quantity)
      # ignore a bad order
      if the_order.order_id == 82386666
        return {:sku=>'NULL',:quantity=>0}
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
        elsif item_count == 4
          rslt = 'SHIP-STD-04'
        elsif item_count >= 5 && item_count <= 9
          rslt = 'SHIP-STD-07'
        else
          raise ArgumentError, "\n\nUnknown ItemCount For ActiveLife\n\nOrder ID:#{the_order.order_id}"
        end
      end
      return rslt
    end


  end
end
