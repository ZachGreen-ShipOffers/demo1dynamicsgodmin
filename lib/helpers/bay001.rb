module DynamicsHelper
  class Bay001 < ShipmentHelper

    @@allowed_skus =%w(
    119-HYDROEYES-109
    210-STRTCHSIL-110
    115-FSKLN-127
    116-GAR-135
    117-GCBE-133
    ).freeze

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      'BOX'
    end

    def shiptype(the_order, items, item_count)
      btls = %w(
      119-HYDROEYES-109
      210-STRTCHSIL-110
      )
      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        btl = false
        items.each do |item|
          if btls.include? item['sku']
            btl = true
            break
          end
        end
        if btl
          if item_count == 1
            rslt = 'SHIP-STD-01'
          elsif item_count == 2
            rslt = 'SHIP-STD-02'
          elsif item_count == 3
            rslt = 'SHIP-STD-03'
          elsif item_count == 4
            rslt = 'SHIP-STD-04'
          elsif item_count == 5
            rslt = 'SHIP-STD-07'
          elsif item_count == 6
            rslt = 'SHIP-STD-08'
          elsif item_count == 7
            rslt = 'SHIP-STD-21'
          elsif item_count == 8
            rslt = 'SHIP-STD-22'
          elsif item_count == 9
            rslt = 'SHIP-STD-23'
          else
            rslt = 'SHIP-STD-11'
          end
        else
          if item_count == 1
            rslt = 'SHIP-HRB-01'
          elsif item_count == 2
            rslt = 'SHIP-HRB-02'
          elsif item_count == 3
            rslt = 'SHIP-HRB-03'
          elsif item_count == 4
            rslt = 'SHIP-HRB-04'
          elsif item_count == 5
            rslt = 'SHIP-HRB-05'
          elsif item_count == 6
            rslt = 'SHIP-HRB-06'
          elsif item_count == 7
            rslt = 'SHIP-HRB-07'
          elsif item_count == 8
            rslt = 'SHIP-HRB-08'
          elsif item_count == 9
            rslt = 'SHIP-HRB-09'
          else
            rslt = 'SHIP-HRB-10'
          end
        end
      end
      return rslt
    end


  end
end
