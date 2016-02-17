module DynamicsHelper
  class Lif001 < ShipmentHelper
    @@allowed_skus =  %w(
      101-BLPR-102
      168-BRNBSTR-103
      141-TSTBLACK-122
      116-GAR-115
      120-JNT-102
      122-KRL30-101
      132-PHYT-107
      172-LIFETABS-109
      137-RASP-114
      181-MCLNSE-119
      181-MCLNSE-112
      233-FSKLN250-101
      240-FCBRN-101
      264-WHEY-101
      134-PROB30-120
    )
    def mapsku(shipment,sku,quantity)
      # force change of old forskoklin
      if sku == '115-FSKLN-106'
        sku = '233-FSKLN250-101'
      elsif sku == '104-MIND' || sku == '104-MIND-101'
        sku = '168-BRNBSTR-103'
      elsif sku == 'COCOABURN' || sku == 'cocaoburn'
        sku = '240-FCBRN-101'
      elsif sku == '166-GAR-115'
        sku = '116-GAR-115'
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{shipment.ship_station_order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end



    def packtype(shipment,items,item_count)
      if item_count <= 6
        return 'BAG'
      else
        return 'BOX'
      end
    end

    def shiptype(shipment,items,item_count)
      if shipment.country != 'US'
        rslt = 'SHIP-INT-01'
      else
        if shipment.carrier_code == 'usps'
          if item_count <= 6
            rslt = 'SHIP-USPS-01'
          elsif item_count >= 7 && item_count <= 13
            rslt = 'SHIP-USPS-02'
          else
            raise "UNKOWN SHIPMENT COUNT FOR USPS and Life Essentials (LIF001)"
          end
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
      end
      return rslt
    end

  end
end
