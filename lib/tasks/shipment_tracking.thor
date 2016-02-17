class ShipmentTracking < Thor

  ShipmentTracking.desc "sendall_standard THE_DATE","Send all tracking For Date"
  def sendall_standard(sdate=nil)
    require './config/environment'  # Load Rails Stuff
    sdate = sdate.to_date rescue Date.today
    sdate = sdate.strftime('%F')
    sql  = <<-FOO
       id in (
        select
          notification_recipients.client_company_id
        from notification_recipients
        where
            notification_recipients.wants_tracking = true and
            notification_recipients.name not in ('LIMELIGHT','ULTRACART','CUSTOM_FTP','CUSTOMFTP')

       )

    FOO
    companies = ClientCompany.where(sql).pluck(:dyna_code)
    companies.each do |company_code|
      ShipmentTracking.new.invoke "shipment_tracking:standard_tracking",[company_code,sdate,sdate]
    end
  end

  ShipmentTracking.desc "sendall_limelight THE_DATE","Send all limelight tracking For Date"
  def sendall_limelight(sdate=nil)
    require './config/environment'  # Load Rails Stuff
    sdate = sdate.to_date rescue Date.today
    sdate = sdate.strftime('%F')
    sql  = <<-FOO
       id in (
        select
          notification_recipients.client_company_id
        from notification_recipients
        where
            notification_recipients.wants_tracking = true and
            notification_recipients.name = 'LIMELIGHT'

       )

    FOO
    companies = ClientCompany.where(sql).pluck(:dyna_code)
    companies.each do |company_code|
      ShipmentTracking.new.invoke 'shipment_tracking:limelight_tracking',[company_code,sdate,sdate]
    end

  end

  ShipmentTracking.desc "sendall_ultracart THE_DATE","Send all ULTRACART tracking For Date"
  def sendall_ultracart(sdate=nil)
    require './config/environment'  # Load Rails Stuff
    sdate = sdate.to_date rescue Date.today
    sdate = sdate.strftime('%F')
    sql  = <<-FOO
       id in (
        select
          notification_recipients.client_company_id
        from notification_recipients
        where
            notification_recipients.wants_tracking = true and
            notification_recipients.name = 'ULTRACART'

       )

    FOO
    companies = ClientCompany.where(sql).pluck(:dyna_code)
    companies.each do |company_code|
      ShipmentTracking.new.invoke 'shipment_tracking:ultracart_tracking',[company_code,sdate,sdate]
    end

  end

  ShipmentTracking.desc "custom_tracking COMPANY_CODE START_DATE END_DATE","Generate and email tracking information for DATE(s)"
  def custom_tracking(company_code,sdate=nil,edate=nil)
    require './config/environment'  # Load Rails Stuff
    require 'net/ftp'
    require 'fileutils'
    require 'csv'
    require 'spreadsheet'

    sdate ||= Time.now()
    edate ||= sdate
    sdate = sdate.to_date
    edate = edate.to_date
    b_date = sdate.strftime("%Y-%m-%d 00:00:00")
    e_date = edate.strftime("%Y-%m-%d 23:59:59")

    rpt_date = sdate.strftime("%Y-%m-%d")

    puts "Processing Custom Tracking For: #{company_code}"
    company = ClientCompany.find_by(dyna_code: company_code)
    company.notification_recipients.where(name: 'CUSTOM_FTP', wants_tracking: true).each do |ftp_info|
      #the_store = ShipStationStore.find(ftp_info.ship_station_store_id)
      shipments = company.shipments.where(voided: false).where('ship_date between ? and ?',b_date,e_date)

      if shipments.count > 0
        out_dir = Dir.tmpdir() + "/#{company_code}"
        if !Dir.exists?(out_dir)
          FileUtils.mkdir_p(out_dir)
        end

        tracking_file = out_dir + "/#{rpt_date}-tracking.xls"
        book = Spreadsheet::Workbook.new
        csv = book.create_worksheet :name => "Shipments"
        cntr = 0
        csv.row(cntr).replace ["MarketPlace","Order Number","Ship Name","Ship Date","Service","Tracking Number"]
        cntr = cntr + 1
        shipments.each do |shipment|
          csv.row(cntr).replace [
                       shipment.store.store_name,
                       shipment.order_number,
                       shipment.name,
                       shipment.ship_date,
                       shipment.carrier_code,
                       shipment.tracking_number
                   ]
          cntr = cntr + 1
          if !shipment.ss_order.nil? && !shipment.ss_order.custom_field3.nil? && !shipment.ss_order.custom_field3.empty?
            onumbers = shipment.ss_order.custom_field3.split(',')
            if !(onumbers.length < 2)
              onumbers.each do |order_number|
                if order_number.strip != shipment.order_number
                  csv.row(cntr).replace [
                                            shipment.store.store_name,
                                            order_number,
                                            shipment.name,
                                            shipment.ship_date,
                                            shipment.carrier_code,
                                            shipment.tracking_number
                                        ]
                  cntr = cntr + 1
                end
              end
            end
          end
        end
        puts "\t Tracking File: #{tracking_file} with #{shipments.length} tracking number(s)"
        book.write tracking_file

        puts "\tUploading #{shipments.length} tracking number(s) to #{ftp_info.ftp_server}/#{ftp_info.ftp_username}"

        if File.exists?(tracking_file)
          Net::FTP.open(ftp_info.ftp_server, ftp_info.ftp_username, ftp_info.ftp_password) do |ftp|
            ftp.chdir(ftp_info.ftp_directory)
            ftp.put(tracking_file)
          end
        end

        puts "\t\tDONE!"


      else
        puts "\tNo Tracking Numbers"
      end
    end
  end

  ShipmentTracking.desc "standard_tracking COMPANY_CODE START_DATE END_DATE","Generate and email tracking information for DATE(s)"
  def standard_tracking(company_code,sdate=nil,edate=nil)
    require './config/environment'  # Load Rails Stuff
    require 'fileutils'
    require 'csv'
    require 'spreadsheet'

    sdate ||= Time.now()
    edate ||= sdate
    sdate = sdate.to_date
    edate = edate.to_date
    b_date = sdate.strftime("%Y-%m-%d 00:00:00")
    e_date = edate.strftime("%Y-%m-%d 23:59:59")

    puts "Processing Standard Tracking For: #{company_code}"
    company = ClientCompany.find_by(dyna_code: company_code)

    shipments = company.shipments.where(voided: false).where('ship_date between ? and ?',b_date,e_date)
    if shipments.count > 0
      tracking_file = Dir.tmpdir + "/#{company.name.parameterize}-#{sdate.strftime('%F')}-#{edate.strftime('%F')}-tracking.xls"
      book = Spreadsheet::Workbook.new
      xls = book.create_worksheet :name => "Shipments"
      cntr = 0
      shipments.each do |shipment|
        xls.row(cntr).replace [
                                  shipment.store.store_name,
                                  shipment.order_number,
                                  shipment.name,
                                  shipment.ship_date,
                                  shipment.carrier_code,
                                  shipment.tracking_number
                              ]
        cntr = cntr + 1
        if !shipment.ss_order.nil? && !shipment.ss_order.custom_field3.nil? && !shipment.ss_order.custom_field3.empty?
          onumbers = shipment.ss_order.custom_field3.split(',')
          if !(onumbers.length < 2)
            onumbers.each do |order_number|
              if order_number.strip != shipment.order_number
                xls.row(cntr).replace [
                    shipment.store.store_name,
                    order_number,
                    shipment.name,
                    shipment.ship_date,
                    shipment.carrier_code,
                    shipment.tracking_number
                ]
                cntr = cntr + 1
              end
            end
          end
        end
      end
      puts "\t Tracking File: #{tracking_file} with #{shipments.length} tracking number(s)"
      book.write tracking_file

      # Get List of People Who Should Receive The Report
      email_list = company.notification_recipients.where(wants_tracking: true).where("name not in ('LIMELIGHT','ULTRACART','CUSTOM_FTP','CUSTOM FTP')").pluck(:email_address).reject { |e| e.to_s.empty? }
      if email_list.length > 0
        puts "\tSending to: #{email_list.join(', ')}"
        ShipmentTrackingMailer.tracking_report(email_list,company_code,company.name,sdate,edate,tracking_file).deliver
      else
        puts "\t No Recipients, sending to shipoffers"
        ShipmentTrackingMailer.tracking_report(['systems+tracking@shipoffers.com'],company_code,company.name,sdate,edate,tracking_file).deliver
      end
    end


  end




  ShipmentTracking.desc "limelight_tracking COMPANY_CODE START_DATE END_DATE","Generate LimeLight Tracking File For DATE(s)"
  def limelight_tracking(company_code,sdate=nil,edate=nil,oname=nil)
    require './config/environment'  # Load Rails Stuff
    require 'net/ftp'
    require 'fileutils'
    require 'csv'

    sdate ||= Time.now()
    edate ||= sdate
    sdate = sdate.to_date
    edate = edate.to_date
    b_date = sdate.strftime("%Y-%m-%d 00:00:00")
    e_date = edate.strftime("%Y-%m-%d 23:59:59")

    puts "Processing LimeLight Tracking For: #{company_code}"

    company = ClientCompany.find_by(dyna_code: company_code)
    company.notification_recipients.where(name: 'LIMELIGHT', wants_tracking: true).each do |ftp_info|
      the_store = ShipStationStore.find(ftp_info.ship_station_store_id)
      shipments = the_store.shipments.where(voided: false).where('ship_date between ? and ?',b_date,e_date)

      if shipments.count > 0
        out_dir = Dir.tmpdir() + "/#{company_code}"
        if !Dir.exists?(out_dir)
          FileUtils.mkdir_p(out_dir)
        end

        tracking_file = out_dir + "/tracking_#{sdate.strftime('%m%d%Y')}.csv"
        csv = CSV.open(tracking_file,'w',{:headers=>['Order Id','Tracking Number'], :write_headers=>true, :force_quotes=>true })
        shipments.each do |shipment|
          csv << [shipment.order_number,shipment.tracking_number]
          if !shipment.ss_order.nil? && !shipment.ss_order.custom_field3.nil? && !shipment.ss_order.custom_field3.empty?
            onumbers = shipment.ss_order.custom_field3.split(',')
            if !(onumbers.length < 2)
              onumbers.each do |order_number|
                if order_number.strip != shipment.order_number
                  csv << [order_number,shipment.tracking_number]
                end
              end
            end
          end
        end
        csv.close

        puts "\t Tracking File: #{tracking_file}"
        puts "\tUploading #{shipments.length} tracking number(s) to #{ftp_info.ftp_server}/#{ftp_info.ftp_username}"

        if File.exists?(tracking_file)
          Net::FTP.open(ftp_info.ftp_server, ftp_info.ftp_username, ftp_info.ftp_password) do |ftp|
            ftp.chdir(ftp_info.ftp_directory)
            ftp.put(tracking_file)
          end
        end

        puts "\t\tDONE!"


      else
        puts "\tNo Tracking Numbers"
      end
    end

  end

  ShipmentTracking.desc "ultracart_tracking COMPANY_CODE START_DATE END_DATE","Generate UltraCart Tracking File For DATE(s)"
  def ultracart_tracking(company_code,sdate=nil,edate=nil)
    require './config/environment'  # Load Rails Stuff
    require 'net/ftp'
    require 'fileutils'
    require 'csv'

    sdate ||= Time.now()
    edate ||= sdate
    sdate = sdate.to_date
    edate = edate.to_date
    b_date = sdate.strftime("%Y-%m-%d 00:00:00")
    e_date = edate.strftime("%Y-%m-%d 23:59:59")

    puts "Processing UltraCart Tracking For: #{company_code}"

    company = ClientCompany.find_by(dyna_code: company_code)
    company.notification_recipients.where(name: 'ULTRACART', wants_tracking: true).each do |ftp_info|
      the_store = ShipStationStore.find(ftp_info.ship_station_store_id)
      shipments = the_store.shipments.where(voided: false).where('ship_date between ? and ?',b_date,e_date)

      if shipments.count > 0
        out_dir = Dir.tmpdir() + "/#{company_code}"
        if !Dir.exists?(out_dir)
          FileUtils.mkdir_p(out_dir)
        end

        tracking_file = out_dir + "/ship#{sdate.strftime('%Y%m%d')}_#{Time.now().strftime('%j%H%I%S%L')}.csv"
        csv = CSV.open(tracking_file,'w',{:headers=>['Order ID','Shipping Date - MM/DD/YYYY','Shipping Method','Tracking Number'], :write_headers=>true, :force_quotes=>true })
        shipments.each do |shipment|
          ship_method = uc_map_shiptype(company_code,shipment.carrier_code,shipment.service_code)
          csv << [shipment.order_number,shipment.ship_date.strftime('%m/%d/%Y'),ship_method,shipment.tracking_number]
          if !shipment.ss_order.nil? && !shipment.ss_order.custom_field3.nil? && !shipment.ss_order.custom_field3.empty?
            onumbers = shipment.ss_order.custom_field3.split(',')
            if !(onumbers.length < 2)
              onumbers.each do |order_number|
                if order_number.strip != shipment.order_number
                  csv << [order_number,shipment.ship_date.strftime('%m/%d/%Y'),ship_method,shipment.tracking_number]
                end
              end
            end
          end
        end
        csv.close


        puts "\t Tracking File: #{tracking_file}"
        puts "\tUploading #{shipments.length} tracking number(s) to #{ftp_info.ftp_server}/#{ftp_info.ftp_username}"

        if File.exists?(tracking_file)
          Net::FTP.open(ftp_info.ftp_server, ftp_info.ftp_username, ftp_info.ftp_password) do |ftp|
            ftp.chdir(ftp_info.ftp_directory)
            ftp.put(tracking_file)
          end
        end

        puts "\t\tDONE!"


      else
        puts "\tNo Tracking Numbers"
      end

    end
  end

  no_commands do

    def uc_map_shiptype(customer_code,carrier_code,service_code)
      rslt = ''
      if customer_code == 'PER001'    # Perfect Origins
        rslt = 'STANDARD'
        if carrier_code == 'express_1'
          rslt = 'USPSPRI'
        elsif carrier_code == 'ups'
          rslt = 'STANDARD'
        elsif carrier_code == 'fedex'
          rslt = 'STANDARD'
        end
      elsif customer_code == 'SIM001' # Simple Smart Science
        rslt = 'UPS: 3 Day Select'
        if carrier_code == 'ups'
          rslt = 'UPS: 3 Day Select'
        elsif ['express_1','stamps_com','endica'].include?(carrier_code)
          rslt = 'USPS: Priority Mail'
        elsif carrier_code == 'fedex'
          rslt = 'FedEx: 2-Day'
        end
      end
      rslt
    end

  end
end