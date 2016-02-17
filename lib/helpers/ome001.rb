module DynamicsHelper
  class Ome001 < ShipmentHelper
    @@allowed_skus =  %w(
        102-BLSG-101
        168-BRNBSTR-104
        181-MCLNSE-114
        148-VISSUPPORT-101
        136-PRSTSUP-101
        141-TSTBLACK-105
        235-TSTOMK-101
        109-CHOL-102
        113-COQOMEGA-101
        132-PHYT-103
        116-GAR-109
        216-FGP-101
        148-VISSUPPORT-102
        102-BLSG-102
        155-IMSUPPORT-101
        127-MVIT-105
        121-OMEGAK-101
        135-PROB60-101
        120-JNT-104
        181-MCLNSE-115
        172-LIFETABS-111
        112-COQ10-104
    ).freeze

    def mapsku(the_order,sku,quantity)
      if sku == '115-FSKLN'
        return {:sku=>'NULL',:quantity=>0}
      elsif sku == '121- OMEGAK' || sku == '129-OMEGAK-101' || sku == '121-OMKEGAK-101' || sku == '121-OMEGA-101'
        sku = '121-OMEGAK-101'
      end
      # pass one to quick map, not perfect but will work
      if !@@allowed_skus.include?(sku)
        @@allowed_skus.each do |s|
          if sku == s[/(\d+\-\w+)/]
            sku = s
            break
          end
        end
      end
      # manual mappings because of bad data
      if !@@allowed_skus.include?(sku)
        if sku == '111-COLN'
          sku = '181-MCLNSE-115'
        end
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.ship_station_order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end

    def packtype(the_order, items,item_count)
      return 'BAG'
    end

    def shiptype(the_order,items, item_count)

      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        if item_count == 1
          rslt = 'SHIP-STD-01'
        elsif item_count == 2
          rslt = 'SHIP-STD-02'
        elsif item_count == 3
          rslt = 'SHIP-STD-03'
        elsif item_count >= 4 && item_count <= 9
          rslt = 'SHIP-STD-05'
        elsif item_count >=10
          rslt = 'SHIP-STD-11'
        end
      end

      return rslt
    end


  end
end
