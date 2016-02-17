module DynamicsHelper
  class Pot001 < ShipmentHelper

    @@allowed_skus =%w(
    116-GAR-114
    134-PROB30-121
    179-KIDNEY-110
    127-MVIT-108
    100-BCAA-106
    128-NO2-105
    141-TSTBLACK-124
    119-HYDROEYES-110
    210-STRTCHSIL-111
    ).freeze

    def mapsku(the_order,sku,quantity)
      case sku
      when 'BT-EW-CREAM'
        sku = '119-HYDROEYES-110'
      when 'BT-TESTOSTERON'
        sku = '141-TSTBLACK-124'
      when 'BT-DAILYMV'
        sku = '127-MVIT-108'
      when 'BT-NO2'
        sku = '128-NO2-105'
      when 'BT-PROBIOTIC'
        sku = '134-PROB30-121'
      when 'Garcinia-BT-1x'
        sku = '116-GAR-114'
      when 'BT-AA-CREAM'
        sku = '210-STRTCHSIL-111'
      when 'BT-BCAA'
        sku = '100-BCAA-106'
      when 'BT-WKBEAN'
        sku = '179-KIDNEY-110'
      end

      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super(the_order,sku,quantity)
    end

    def packtype(the_order, items, item_count)
      'BOX'
    end

    def shiptype(the_order, items, item_count)
      if the_order.country_code != 'US'
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
      end
      return rslt
    end


  end
end
