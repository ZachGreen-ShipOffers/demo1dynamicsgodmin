module DynamicsHelper
  class Ult003 < ShipmentHelper
    @@allowed_skus =  %w(

      241-BIOPRO-101
      122-KRL30-119
      181-MCLNSE-134
      276-C3NP-101
      121-OMEGAK-102
      148-VISSUPPORT-106
      181-MCLNSE-145
      168-BRNBSTR-129
      135-PROB60-102
      120-JNT-122

    ).freeze

    def mapsku(the_order,sku,quantity)
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
