module DynamicsHelper
  class Tes001 < ShipmentHelper
    @@allowed_skus =  %w(
      141-TSTBLACK-114
      122-KRL30-112
      100-BCAA-104
      181-MCLNSE-128
      116-GAR-117
      118-HGASPRAY-104
      178-VPRXBLK-102
      128-NO2-104
    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == '141-TSTBLACK-103'
        sku = '141-TSTBLACK-114'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      rslt = 'BAG'
      if item_count > 6
        rslt = 'BOX'
      end
      return rslt
    end

    def shiptype(the_order, items, item_count)

      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        if item_count >= 1 && item_count <= 5
          rslt = 'SHIP-STD-17'
        elsif item_count >=6 && item_count <= 9
          rslt = 'SHIP-STD-09'
        else
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end


  end
end
