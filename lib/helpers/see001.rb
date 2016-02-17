module DynamicsHelper
  class See001 < ShipmentHelper

    def mapsku(the_order,sku,quantity)
      # kill NULL
      if sku == 'NULL'
        return {:sku=>'NULL',:quantity=>0}
      end

      if !@@allowed_skus.include?(sku)
        mrslt = GenericSku.where(map_name: 'SEED',sku: sku.strip.upcase).first

        if !mrslt.nil?
          sku = mrslt.client_sku
          quantity = quantity * mrslt.quantity
        end
      end

=begin
      if !@@allowed_skus.include?(sku)
        @@allowed_skus.each do |s|
          if sku == s[/(\d+\-\w+)/]
            sku = s
            break
          end
        end
      end
=end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end



    def packtype(the_order,items,item_count)
      has_backpack = false
      items.each do |item|
        if @@backpaks.include?(item[:sku])
          has_backpack = true
          break
        end
      end

      return 'BOX'
    end

    def shiptype(the_order,items,item_count)
      rslt = nil
      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        has_backpack = false
        backpack_count = 0
        items.each do |item|
          if @@backpaks.include?(item[:sku])
            has_backpack = true
            backpack_count = backpack_count + 1
          end
        end
        if has_backpack
          if backpack_count == 1
            rslt = 'SHIP-BKP-01'
          elsif backpack_count == 2
            rslt = 'SHIP-BKP-02'
          elsif backpack_count == 3
            rslt = 'SHIP-BKP-03'
          else
            rslt = nil
          end
        else
          if item_count == 1
            rslt = 'SHIP-STD-01'
          elsif item_count == 2
            rslt = 'SHIP-STD-02'
          elsif item_count == 3
            rslt = 'SHIP-STD-03'
          else
            rslt = nil
          end
        end
      end
      raise ArgumentError,"\n\nUnknown Shipment Quantity / Type:\n Order ID:#{the_order.order_id}" if rslt.nil?
      return rslt
    end

    @@allowed_skus =  %w(

        229-MMBHK-101
        231-TFEMTK-101
        230-WDK-101
        228-ISOMAG-101
        243-20MLGRN-101
        244-20MLCAM-101
        245-20MLTAN-101
        246-20MLBLK-101
        267-LEGGAL-101
    268-LEGGNS-101
    269-LEGNTL-101
    270-LEGSKL-101
    271-LEGMSL-101

)

    @@backpaks = %w(
        243-20MLGRN-101
        244-20MLCAM-101
        245-20MLTAN-101
        246-20MLBLK-101
    )

  end
end
