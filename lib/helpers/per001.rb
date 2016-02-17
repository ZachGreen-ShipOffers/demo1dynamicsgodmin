module DynamicsHelper
  class Per001 < ShipmentHelper
    @@company_name = 'Perfect Origins'.freeze

    @@allowed_skus = %w(
      171-QDRNG-101
      124-POLIVLEAN-101
      166-POOMEGA-101
      132-PHYT-105
      166-POOMEGA-102
      133-POPROBIO-101
      181-MCLNSE-101
      232-FBBOOK-101
      236-DRKCLNSE-101
      228-ISOMAG-102
      258-PFTBAL-101
      219-FANO2-101
    ).freeze

    def mapsku(shipment,sku,quantity)
      if sku == '166-POOMEGA-101166-POOMEGA-101'
        sku = '166-POOMEGA-101'
      elsif sku == 'BOOK'
       sku = '232-FBBOOK-101'
      elsif sku == '181-MCLNSE-101'   # @todo need to find some way to switch between sku's
        sku = '236-DRKCLNSE-101'
      elsif sku == '124-POLIVLEAN' || sku == '214-POLIVLEAN-101'
        sku = '124-POLIVLEAN-101'
      elsif sku == '133-POPORBIO-101'
        sku = '133-POPROBIO-101'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{shipment.ship_station_order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(shipment,items,item_count)
      return 'BOX'
    end

    def shiptype(shipment,items,item_count)
      if shipment.country != 'US'
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
        elsif item_count >= 5 && item_count <=9
          rslt = 'SHIP-STD-07'
        else
          rslt = 'SHIP-STD-11'
        end

      end
      return rslt
    end
  end
end
