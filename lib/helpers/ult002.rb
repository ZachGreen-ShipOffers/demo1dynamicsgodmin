module DynamicsHelper
  class Ult002 < ShipmentHelper
    @@allowed_skus =  %w(

      168-BRNBSTR-107
      172-LIFETABS-103
      168-BRNBSTR-110
      142-TSTWHITE-105
      120-JNT-121
      181-MCLNSE-124

    ).freeze

    def mapsku(the_order,sku,quantity)

      if !@@allowed_skus.include?(sku)
        mrslt = GenericSku.where(map_name: 'ULTPLAB',sku: sku.strip.upcase).first
        if !mrslt.nil?

            sku = mrslt.client_sku
            quantity = quantity.to_i * mrslt.quantity.to_i

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
        elsif item_count == 5
          rslt = 'SHIP-STD-06'
        elsif item_count >= 6 && item_count <= 9
          rslt = 'SHIP-STD-09'
        else
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end


  end
end
