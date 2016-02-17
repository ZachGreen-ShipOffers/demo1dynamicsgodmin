module DynamicsHelper
  class Lea001 < ShipmentHelper

    def mapsku(the_order,sku,quantity)
      # kill NULL
      if sku == 'NULL'
        return {:sku=>'NULL',:quantity=>0}
      end
      if sku == '115-FSKLN-125'
        sku = '115-FSKLN-124'
      end
      if sku == 'CMXLC'
        sku = '168-BRNBSTR-122'
      elsif sku == '176-STRTCHCRM' || sku == '210-STRTYCHSIL-1002'
        sku = '210-STRTCHSIL-102'
      elsif sku == 'KB'
        sku = '134-PROB30-108'
      elsif sku == '111-COLN'
        sku = '181-MCLNSE-109'
      elsif sku == '181-MCLNSE-110'
        sku = '181-MCLNSE-109'
      elsif sku == '115FSKLN-119' || sku == '-115FSKLN-119'
        sku = '115-FSKLN-119'
      elsif sku == '168-BRNBSTR-120' || sku == '214-ENERGY-102'
        sku = '168-BRNBSTR-122'
      elsif sku == 'NPBSC'
        sku = '102-BLSG-110'
      end
      if !@@allowed_skus.include?(sku)
        @@allowed_skus.each do |s|
          if sku == s[/(\d+\-\w+)/]
            sku = s
            break
          end
        end
      end
      raise ArgumentError,"\n\nUnknown SKU Found:\n Order ID:#{the_order.order_id}\tSKU: #{sku}\n\n" unless @@allowed_skus.include?(sku)
      super
    end



    def packtype(the_order,items,item_count)
      has_cream = false
      items.each do |item|
        if item['sku'] == '210-STRTCHSIL-102' || item['sku'] == '210-STRTCHSIL'
          has_cream = true
          break
        end
      end
      if item_count <= 6 && has_cream == false
        return 'BAG'
      else
        return 'BOX'
      end
    end

    def shiptype(the_order,items,item_count)
      if the_order.ship_station_store_id == 45506
        rslt = 'SHIP-AMZ-01'
        return rslt
      end
      if the_order.country_code != 'US'
        rslt = 'SHIP-INT-01'
      else
        has_cream = false
        items.each do |item|
          if item['sku'] == '210-STRTCHSIL-102' || item['sku'] == '210-STRTCHSIL'
            has_cream = true
            break
          end
        end
        if has_cream
          if item_count == 1
            rslt = 'SHIP-CRM-01'
          elsif item_count == 2
            rslt = 'SHIP-CRM-02'
          elsif item_count >=3 && item_count <= 4
            rslt = 'SHIP-CRM-03'
          elsif item_count == 5
            rslt = 'SHIP-CRM-04'
          else
            rslt = 'SHIP-CRM-05'
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
          elsif item_count == 5
            rslt = 'SHIP-STD-06'
          elsif item_count >=6 && item_count <= 9
            rslt = 'SHIP-STD-09'
          else
            rslt = 'SHIP-STD-11'
          end
        end
      end

      return rslt
    end

    @@allowed_skus =  %w(

        100-BCAA-101
        101-BLPR-101
        102-BLSG-103
        102-BLSG-106
        102-BLSG-107
        102-BLSG-110
        102-BLSG-111
        109-CHOL-101
        112-COQ10-101
        114-FISHOIL-102
        114-FISHOIL-103
        114-FISHOIL-106
        114-FISHOIL-107
        115-FSKLN-101
        115-FSKLN-102
        115-FSKLN-107
        115-FSKLN-111
        115-FSKLN-112
        115-FSKLN-115
        115-FSKLN-116
        115-FSKLN-119
        116-GAR-102
        116-GAR-118
        116-GAR-119
        116-GAR-120
        117-GCBE-103
        117-GCBE-106
        117-GCBE-113
        117-GCBE-114
        117-GCBE-115
        117-GCBE-124
        119-HYDROEYES-101
        119-HYDROEYES-102
        119-HYDROEYES-108
        120-JNT-101
        120-JNT-109
        123-KRL60-101
        127-MVIT-101
        127-MVIT-102
        127-MVIT-103
        127-MVIT-106
        127-MVIT-107
        128-NO2-101
        132-PHYT-101
        132-PHYT-102
        132-PHYT-104
        132-PHYT-108
        132-PHYT-109
        132-PHYT-110
        132-PHYT-111
        132-PHYT-112
        132-PHYT-113
        134-PROB30-101
        134-PROB30-103
        134-PROB30-108
        134-PROB30-110
        134-PROB30-111
        134-PROB30-112
        134-PROB30-113
        134-PROB30-114
        134-PROB30-115
        137-RASP-103
        137-RASP-110
        137-RASP-111
        137-RASP-112
        140-THYRO-101
        140-THYRO-102
        140-THYRO-103
        141-TSTBLACK-102
        141-TSTBLACK-107
        141-TSTBLACK-108
        141-TSTBLACK-116
        141-TSTBLACK-117
        141-TSTBLACK-118
        141-TSTBLACK-119
        141-TSTBLACK-120
        141-TSTBLACK-121
        146-VPRXBLUE-101
        154-PAINR-101
        154-PAINR-103
        154-PAINR-104
        167-CLA-101
        168-BRNBSTR-101
        168-BRNBSTR-102
        168-BRNBSTR-105
        168-BRNBSTR-116
        168-BRNBSTR-117
        168-BRNBSTR-118
        168-BRNBSTR-119
        168-BRNBSTR-122
        169-DRUGFREE-101
        172-LIFETABS-101
        172-LIFETABS-106
        172-LIFETABS-107
        172-LIFETABS-108
        179-KIDNEY-102
        179-KIDNEY-103
        179-KIDNEY-104
        181-MCLNSE-109
        189-VTMND3-101
        189-VTMND3-102
        196-MRNED3-101
        196-MRNED3-102
        197-BDRDOM-101
        205-FLORA7-101
        205-FLORA7-102
        206-GRNTEA-101
        206-GRNTEA-102
        206-GRNTEA-103
        210-STRTCHSIL-102
        210-STRTCHSIL-108
        214-ENERGY-101
        214-ENERGY-102
        238-5HTP-101
        115-FSKLN-120
        168-BRNBSTR-121
        120-JNT-112
        266-VCSRM-101
        115-FSKLN-124
        288-FCLFT-102
        322-MRSB-101
)

  end
end
