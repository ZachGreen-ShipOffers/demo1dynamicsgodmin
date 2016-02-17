module DynamicsHelper
  class Rou001 < ShipmentHelper
    @@allowed_skus =  %w(

      117-GCBE-107
      168-BRNBSTR-113
      165-YACROOT-102
      116-GAR-112
      115-FSKLN-108
      181-MCLNSE-126
      181-MCLNSE-125
      132-PHYT-106
      122-KRL30-118
      114-FISHOIL-109
      134-PROB30-116
      137-RASP-107
      165-YACROOT-102
      138-SAFF-108
      107-BRSCREAM-106
      146-VPRXBLUE-104

    ).freeze

    def mapsku(the_order,sku,quantity)

      if !@@allowed_skus.include?(sku)
        @@allowed_skus.each do |s|
          if sku == s[/(\d+\-\w+)/]
            sku = s
            break
          end
        end
      end

      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      rslt = 'BAG'
      return rslt
    end

    def shiptype(the_order, items, item_count)
      rslt = ''
      if the_order.country_code != 'US'
        if !the_order.ss_order.nil? && !the_order.ss_order.custom_field2.nil? && !the_order.ss_order.custom_field2.empty? && the_order.ss_order.custom_field2.upcase.strip == 'BULK'
          rslt = 'SHIP-INT-04'
        elsif the_order.carrier_code == 'fedex'
          rslt = 'SHIP-INT-03'
        elsif the_order.carrier_code == 'ups'
          rslt = 'SHIP-INT-02'
        elsif the_order.carrier_code == 'usps'
          rslt = 'SHIP-INT-05'


        end
      end
      raise Exception.new("Unknown RouseHill Shipment Type") if rslt.empty?
      return rslt
    end


  end
end
