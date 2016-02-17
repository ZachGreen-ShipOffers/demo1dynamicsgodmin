module DynamicsHelper
  class Sim001 < ShipmentHelper
    @@allowed_skus =  %w(

      181-MCLNSE-123
      212-MBD-101
      213-MBN-101
      134-PROB30-105
      291-BRNBK-101

    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == '212-MBD'
        sku = '212-MBD-101'
      end
      if !@@allowed_skus.include?(sku)
        mrslt = GenericSku.where(map_name: 'SMART',sku: sku.strip.upcase).first
        if !mrslt.nil?
          if mrslt.client_sku != 'MB-TOTAL'
            sku = mrslt.client_sku
            quantity = quantity * mrslt.quantity
          else
            sku = ['212-MBD-101','213-MBN-101']
            qtmp = quantity * mrslt.quantity
            quantity = [qtmp, qtmp]
            return {:sku=>sku,:quantity=>quantity}
          end
        end
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      rslt = 'BOX'
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
          rslt = 'SHIP-STD-11'
        end
      end
      return rslt
    end


  end
end
