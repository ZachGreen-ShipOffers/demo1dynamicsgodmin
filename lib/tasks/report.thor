class Report < Thor
  require 'net/ftp'
  require './config/environment' # Load Rails Stuff

  desc "csv START_DATE END_DATE STORE_CODE","create shipment CSV for all or specified store from start date to end date"

  def csv(start_date,end_date,store='')
    sd = Date.parse(start_date)
    ed = end_date.empty? ? sd : (Date.parse(end_date) rescue Date.today)
    store_array =[]
    if !store.empty?
      store_array = store.split(' ')
      store_array.each do |s|
        s.upcase!
      end
    end
    companies = get_companies(store_array)
    csv = open_csv(sd,ed)
    companies.each do |c|
      a = [c.dyna_code]
      for d in 0..(ed - sd)
        a << build_csv(c, (sd+d))
      end
      csv << a
    end
    close_csv(csv)
  end

  no_commands{

    def get_companies(store=[])
      if store.empty?
        return ClientCompany.where(run_export: true)
      else
        return ClientCompany.where(dyna_code: store, run_export: true)
      end
    end

    def open_csv(sd,ed)
      out_dir = "/tmp/company_shipment_reports"
      if Dir.exists?(out_dir) == false
        FileUtils.mkdir_p(out_dir)
      end
      file = "#{out_dir}/#{sd.to_s.gsub('-','')}-#{ed.to_s.gsub('-','')}.csv"
      csv = CSV.open(file, 'w', force_quotes: true)
      header = ['Store']
      for d in 0..(ed - sd)
        header << (sd+d).strftime('%m/%d/%Y')
      end
      csv << header
      return csv
    end
    def build_csv(company, d)
      company.shipments.where("ship_station_shipments.ship_date = '#{d}'").count

    end
    def close_csv(csv)
      csv.close
      Net::FTP.open('','admin','admin') do |ftp|
        ftp.chdir('/weekly_reports')
        ftp.put(csv.path)
      end
    end
    def email_csv
      # no more than 15MB

    end

  }

end
