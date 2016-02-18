module DynamicsHelper

  class Cle001 < ShipmentHelper
    @@allowed_skus =  %w(255-CLRALL-101 259-CLRAMST-101 260-CLROIL-101 261-CLRSPT-101 262-CLRBG1-101 263-CLRALL-101)

    def mapsku(the_order,sku,quantity)
      if sku == '1O-DP5L-RR4S'
        return {
          :sku => ['263-CLRALL-101','259-CLRAMST-101','260-CLROIL-101','262-CLRBG1-101'],
          :quantity => [1 * quantity.to_i,1 * quantity.to_i,1 * quantity.to_i,1 * quantity.to_i]
        }
      end
      if sku == 'NG-4UTI-5HGU'
        return {
          :sku => ['255-CLRALL-101','259-CLRAMST-101','260-CLROIL-101','262-CLRBG1-101'],
          :quantity => [1 * quantity.to_i,1 * quantity.to_i,1 * quantity.to_i,1 * quantity.to_i]
        }
      end
      if sku == 'RZ-XASL-7LQZ'
        sku = '259-CLRAMST-101'
      end
      if sku == '7S-GTN5-JJ79'
        sku = '260-CLROIL-101'
      end
      if sku == '1A-27J1-LEJ4'
        sku = '261-CLRSPT-101'
      end
      # raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.ship_station_order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      sku_error(the_order, sku) unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order,items,item_count)
      'BOX'
    end

    def shiptype(the_order,items,item_count)
      # is_kit = the_order.ss_order.items.all? {|item| %w(255-CLRALL-101 259-CLRAMST-101 260-CLROIL-101 262-CLRBG1-101).include? item[:sku]}
      is_kit = false
      items.each do |k,v|
        if %w(255-CLRALL-101 259-CLRAMST-101 260-CLROIL-101 262-CLRBG1-101).include? k[:sku]
          is_kit = true
        else
          is_kit = false
        end
      end

      if is_kit
        if item_count == 4
          rslt = 'SHIP-KIT-01'
        elsif item_count == 8
          rslt = 'SHIP-KIT-02'
        elsif item_count == 12
          rslt = 'SHIP-KIT-03'
        elsif item_count == 16
          rslt = 'SHIP-KIT-04'
        end
      else
        rslt = 'SHIP-STD-01' if item_count == 1
        rslt = 'SHIP-STD-02' if item_count == 2
        rslt = 'SHIP-STD-03' if item_count == 3
        rslt = 'SHIP-STD-04' if item_count == 4

        # ap "# of items #{items.length}"
        # ap "ID: #{the_order.ship_station_order_id}"
        # raise ArgumentError,'Combination of items can not make a whole number of full kits!'
      end
      return rslt
    end

  end

end
