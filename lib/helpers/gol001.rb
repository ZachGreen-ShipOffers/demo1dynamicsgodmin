module DynamicsHelper


  class Gol001 < ShipmentHelper

    @@allowed_skus =  %w(
      303-CPMDE-101
    ).freeze

    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      rslt = 'BOX'
      return rslt
    end

    def shiptype(the_order, items, item_count)
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
      elsif item_count == 6
        rslt = 'SHIP-STD-08'
      end
      return rslt
    end
  end
end
