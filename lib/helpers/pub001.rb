module DynamicsHelper

  class Pub001 < ShipmentHelper

    @@allowed_skus = %w(
      148-VISSUPPORT-104
      155-IMSUPPORT-102
      134-PROB30-118
      282-DRKSPT-101
      210-STRTCHSIL-113
      287-SRVLBOOK-101
      302-RFID-101
312-ARMUP-101
    )
    @book = false

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end



    # these are not real commands
    def packtype(the_order,items,item_count)
      items.each do |i|
        if i['sku'] == '287-SRVLBOOK-101'
          @book = true
          return 'BAG'
        end
      end
      @book = false
      return 'BOX'
    end


    def shiptype(the_order,items,item_count)
      if @book
        return 'SHIP-BOOK-01'
      end
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
