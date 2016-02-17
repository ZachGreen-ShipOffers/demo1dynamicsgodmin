module DynamicsHelper
  class Jeu001 < ShipmentHelper
    @@allowed_skus =  %w(
    186-FRCHEYE-101
184-RJVCRM-101
188-TSTBLN-101
185-RJVSRM-101
187-RAZKEY-101
185-RJVSRM-102
210-STRTCHSIL-104
119-HYDROEYES-105
118-HGASPRAY-106
118-HGASPRAY-105
210-STRTCHSIL-107
181-MCLNSE-137
    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == '200-RC30'
        sku = '184-RJVCRM-101'
      elsif sku == 'EYESILK'
        sku = '185-RJVSRM-102'
      elsif sku == '201-RJSE'
        sku = '185-RJVSRM-101'
      elsif sku == 'MGH-6-VIPLC' # multiple sku, need to send back array
        info={
          :sku=>['118-HGASPRAY-105','181-MCLNSE-137'],
          :quantity=>[6 * quantity.to_i, 2 * quantity.to_i]
        }
        return info
      elsif sku == 'MGH-3-VIPLC'
        return {
          :sku => ['118-HGASPRAY-105','181-MCLNSE-137'],
          :quantity => [3 * quantity.to_i, quantity.to_i]
        }
      elsif sku == 'GL-3'
        sku = '118-HGASPRAY-106'

      end

      date = Date.parse('2015-06-17 00:00:00').to_time
      ship_date = the_order.ship_date

      if date <= ship_date && sku == '184-RJVCRM-101'
        sku = '210-STRTCHSIL-107'
      end

      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(the_order,items,item_count)
      return 'BOX'
    end

    def shiptype(the_order, items, item_count)
      rslt = nil
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
        else
          rslt = 'SHIP-STD-10' # 6+ bottle order
        end
      end
      raise "Uknown Item Count #{item_count}" if rslt.nil?
      return rslt
    end


  end
end
