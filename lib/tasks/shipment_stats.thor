class ShipmentStats < Thor
  require 'csv'
  require './config/environment' # Load Rails Stuff
  desc "collect FILE_NAME","Parse Manifest file to get number of shipments"
  # Export.method_option :ftp, type: :boolean, default: false
  def parse(file, date)
    codes = {}
    total = 0
    CSV.foreach(file) do |row|
      code = /^[A-Z]{3,3}[0-9]{3,3}/.match(row[0])[0] rescue next
      if codes.key? code
        codes[code] = codes[code] + 1

      else
        codes[code] = 1

      end
      codes.delete_if {|k,v| k.nil? }
    end

    codes.each do |k,v|
      cpny = ClientCompany.where(dyna_code: k).first
      if cpny.nil?
        # ap "#{k} ==> #{v}"
        # codes.delete k
        codes[k] = [k, v]
        total += v
        next
      end
      total += v
      codes[k] = [cpny.name, v]
      check = ShipmentStat.where(dyna_code: k, ship_date: date, client_company_id: cpny.id).first
      if !check.nil?
        ap "Updated #{k} for #{date} with #{v}"
        check.shipment_count = v
        ap "#{check.save!}"
        next
      end
      ss = ShipmentStat.create!(dyna_code: k, shipment_count: v, ship_date: date, client_company_id: cpny.id)
      ap "#{k} #{ss.valid?}"
    end
    ap total
    ap 'sending email'
    r = ['zach@shipoffers.com','shawn@shipoffers.com','dave@shipoffers.com','doug@shipoffers.com','chris@shipoffers.com', 'tony@shipoffers.com', 'gil@shipoffers.com','josh@shipoffers.com']
    ShipmentStatsMailer.go_out(r,date,codes,total).deliver_now
  end
end
