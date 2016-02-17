module DynamicsHelper
  class Vit001 < ShipmentHelper
    @@allowed_skus =  %w(

      181-MCLNSE-105
      115-FSKLN-109
      116-GAR-108
      117-GCBE-109
      120-JNT-108
      122-KRL30-108
      168-BRNBSTR-114
      172-LIFETABS-110
      114-FISHOIL-108
      134-PROB30-109
      141-TSTBLACK-110
      165-YACROOT-103
      total-discount

    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == '164-WHTMUL-101' || sku == '164-WHTMUL'
        return {:sku=>'NULL',:quantity=>0}
      end
      if !@@allowed_skus.include?(sku)
        mrslt = GenericSku.where(map_name: 'VITAWEB',sku: sku.strip.upcase).first

        if !mrslt.nil?
            sku = mrslt.client_sku
            quantity = quantity * mrslt.quantity
        end
      end
      if sku == '164-WHTMUL-101' || sku == '164-WHTMUL'
        return {:sku=>'NULL',:quantity=>0}
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
