module DynamicsHelper

  class Ult001 < ShipmentHelper
    @@allowed_skus =  %w(
    120-JNT-113
    )


    def mapsku(the_order,sku,quantity)
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order,items,item_count)
      'BOX'
    end

    def shiptype(the_order,items,item_count)
      super(the_order,items,item_count)
    end
  end
end
