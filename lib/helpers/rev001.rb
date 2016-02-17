
module DynamicsHelper


  class Rev001 < ShipmentHelper

    @@allowed_skus =  %w(

      181-MCLNSE-133
      116-GAR-126
      242-GAR90-101

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
      rslt = 'BAG'
      return rslt
    end

    def shiptype(the_order, items, item_count)
      rslt = nil
        if the_order.country_code != 'US'
          rslt = nil
        else
        if item_count == 1
          rslt = 'SHIP-STD-01'
        elsif item_count == 2
          rslt = 'SHIP-STD-02'
        elsif item_count == 3
          rslt = 'SHIP-STD-03'
        else
          rslt = nil
        end
      end
      raise ArgumentError,"\n\nUnknown Shipment Quantity / Type:\n Order ID:#{the_order.order_id}" if rslt.nil?
      return rslt
    end


  end
end
