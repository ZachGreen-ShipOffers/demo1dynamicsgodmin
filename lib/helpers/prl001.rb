module DynamicsHelper


  class Prl001 < ShipmentHelper

    @@allowed_skus =  %w(134-PROB30-123 225-TRMRIC-103).freeze

    def mapsku(the_order,sku,quantity)
      case sku
      when '10-1002'
        sku = '225-TRMRIC-103'
      when '10-1001'
        sku = '134-PROB30-123'
      end


      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      return 'BOX'
    end

    def shiptype(the_order, items, item_count)
      if the_order.country_code != 'US'
        return 'SHIP-INT-01'
      else
        return 'SHIP-STD-01' if item_count == 1
        return 'SHIP-STD-02' if item_count == 2
        return 'SHIP-STD-03' if item_count == 3
        return 'SHIP-STD-04' if item_count == 4
        return 'SHIP-STD-06' if item_count == 5
        return 'SHIP-STD-08' if item_count == 6
        return 'SHIP-STD-21' if item_count == 7
        return 'SHIP-STD-22' if item_count == 8
        return 'SHIP-STD-23' if item_count == 9
        return 'SHIP-STD-11' if item_count <= 10
      end
    end
  end
end
