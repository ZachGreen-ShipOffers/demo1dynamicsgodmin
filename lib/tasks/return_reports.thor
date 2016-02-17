class ReturnReports < Thor

  ReturnReports.desc "send_all SDATE EDATE","Run all returns reports from SDATE to EDATE"
  def send_all(sdate,edate)
    require './config/environment' # Load Rails Stuff
    companies = ClientCompany.where("id in (select notification_recipients.client_company_id from notification_recipients where notification_recipients.wants_returns = true)").pluck(:dyna_code)
    companies.each do |the_code|
      ReturnReports.new.invoke 'return_reports:daily',[the_code,sdate,edate]
    end
  end

  ReturnReports.desc "daily COMPANY_CODE START_DATE END_DATE","Run Daily Report For Company"
  def daily(company_code,sdate=nil,edate=nil)
    require './config/environment' # Load Rails Stuff
    sdate = sdate.nil? ? Date.today : sdate.to_date rescue Date.today
    edate = edate.nil? ? sdate : edate.to_date rescue sdate

    company_code = company_code.upcase.strip

    puts "Processing: #{company_code} for #{sdate.strftime('%F')} thru #{edate.strftime('%F')}"

    headers = [
        'Order Number',
        'Return Date',
        'RMA #',
        'Ship Name',
        'Returned Items',
        'Restocked Items',
        (company_code != 'PER001') ? 'Damaged' : 'Sent Back',
        'Reason',
        'Comments'
    ].freeze

    company = ClientCompany.find_by(dyna_code: company_code)

    if !company.nil?
      returns = company.returns.where("returned_on between ? and ?",sdate,edate)
      if returns.count > 0
        cntr = 0
        # create spreadsheet
        book = Spreadsheet::Workbook.new
        xls = book.create_worksheet :name=>"Returned Shipments"
        xls.row(cntr).replace(headers)
        returns.each do |rtn|
          returned = []
          restocked = []
          damaged = []
          1.upto(10) do  |c|
            vsel = '%02d' % c
            sku = rtn.send("sku_#{vsel}")
            break if sku.nil? || sku.empty?
            #puts "Checking #{sku}"
            real_info = ReturnSku.find_by(code: sku) rescue nil
            if real_info.nil?
              puts "opps couldn't find it"
              next
            end
            r1 = rtn.send("returned_#{vsel}") rescue 0
            r2 = rtn.send("restock_#{vsel}") rescue 0
            r3 = rtn.send("damagaed_#{vsel}") rescue 0

            returned << "#{real_info.name} x #{r1}"
            restocked << "#{real_info.name} x #{r2}" if r2.to_i > 0
            damaged << "#{real_info.name} x #{r3}" if r3.to_i > 0

          end
          cntr = cntr + 1
          xls.row(cntr).replace([
              rtn.order_numbers,
              rtn.returned_on,
              rtn.rma_numbers,
              rtn.customer,
              returned.join(", "),
              restocked.join(", "),
              damaged.join(", "),
              (rtn.reason_code.nil? == false) ? rtn.reason_code.name : 'return',
              rtn.comments
          ])

        end

        # Save Worksheet
        out_name = Dir.tmpdir()  + "/#{company.name.parameterize}-#{sdate.strftime('%F')}-#{edate.strftime('%F')}-returns.xls"
        puts "\tSaving #{cntr-1} Return(s) SpreadSheet: #{out_name}"
        book.write out_name

        # Get List of People Who Should Receive The Report
        email_list = company.notification_recipients.where(wants_returns: true).pluck(:email_address).reject { |e| e.to_s.empty? }
        #puts "I would have sent to the following:\n#{email_list.join("\n")}"
        ReturnsMailer.returns_report(email_list,company_code,company.name,sdate,edate,out_name).deliver
      end

    else
      puts "\tNo Returns For Company #{company.name} code #{company_code}"
    end

  end

  ReturnReports.desc "restock STORE_CODE START_DATE END_DATE","Restock Report (Date is start of week"
  def restock(store_code,start_date=nil,end_date=nil)
    require './config/environment'  # Load Rails Stuff
    require 'fileutils'
    require 'spreadsheet'
    require 'pp'

    range = 6

    start_date = start_date.to_date rescue Date.today()
    end_date = end_date.to_date rescue  start_date + range.to_i.days
    day_list = []
    all_skus = {}


      the_company = ClientCompany.find_by(dyna_code: store_code)


    sdate = start_date.strftime('%Y-%m-%d')
    edate = end_date.strftime('%Y-%m-%d')
    if store_code != 'LEA001'
      idlist = the_company.stores.pluck(:id).join(',')
    else
      tlist = []
      ClientCompany.where("dyna_code in ('LEA001','BLA001')").each do |c|
        c.stores.each{|s| tlist << s.id; }
      end
      idlist = tlist.join(',')
    end

    # build the list of sku's for the report
    sku_sql = <<-eos
        select distinct sku_01 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_02 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_03 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_04 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_05 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_06 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_07 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_08 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_09 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        union select distinct sku_10 as sku from client_shipment_returns where ship_station_store_id in (#{idlist}) and (returned_on between '#{sdate}' and '#{edate}')
        order by sku
    eos
    sku_rslts = ActiveRecord::Base.connection.exec_query(sku_sql)
    rpt_skus = ['Returned'] + sku_rslts.rows.flatten.reject{|r| r.to_s.empty?; }.sort
    ap rpt_skus

    sku_totals = Hash[rpt_skus.zip(Array.new(rpt_skus.length,0))]

    rpt_rows = {}
    start_date.upto(end_date).each do |d|
      puts "Processing: #{d}"
      the_hash =  Hash[rpt_skus.zip(Array.new(rpt_skus.length,0))]


      the_cnt = ClientShipmentReturn.where("ship_station_store_id in (#{idlist}) and (returned_on between '#{d.strftime('%Y-%m-%d')} 00:00:00' and '#{d.strftime('%Y-%m-%d')} 23:59:59') ").count
      puts "\t there were #{the_cnt} returns"
      the_hash['Returned'] = the_cnt.to_i
      sku_totals['Returned'] = sku_totals['Returned'] + the_hash['Returned']

      rpt_skus.each do |the_sku|
        next if the_sku == 'Returned'
        the_hash[the_sku] = 0
        puts "\tChecking: #{the_sku}"
        1.upto(10).each do |cntr|

          restock_fld = "restock_%02d" % cntr
          sku_fld = "sku_%02d" % cntr
          puts "#\t\tColumn: #{cntr} - #{sku_fld} #{restock_fld}"
          sum_sql =<<-eos
                select

                  sum(#{restock_fld}) as amt
                from client_shipment_returns
                where
                  ship_station_store_id in (#{idlist}) and
                  (returned_on between '#{d.strftime('%Y-%m-%d')}' and '#{d.strftime('%Y-%m-%d')}') and
                  #{sku_fld} = '#{the_sku}'
          eos
          #puts "\n\n#{sum_sql}\n\n"
          sum_rslt = ActiveRecord::Base.connection.exec_query(sum_sql)
          #pp sum_rslt
          the_hash[the_sku] = the_hash[the_sku]  + sum_rslt.to_hash[0]['amt'].to_i

        end

        sku_totals[the_sku] = sku_totals[the_sku] + the_hash[the_sku]
      end
      rpt_rows[d.strftime('%Y-%m-%d')] = the_hash

    end

    rpt_rows['Totals'] = sku_totals



    book = Spreadsheet::Workbook.new
    csv = book.create_worksheet :name=>"Restock"
    cntr = 0

    # add titles
    titles = ['Date'] + rpt_skus
    csv.row(cntr).replace titles

    cntr = cntr + 1
    # do the data
    rpt_rows.each do |d,h|
      next if h['Returned'] == 0
      pp [d] + h.values
      vals = [d] + h.values
      csv.row(cntr).replace(vals)
      cntr = cntr + 1
    end




    out_dir = File.expand_path(Dir.tmpdir + "/external_files/restock")
    if !Dir.exists?(out_dir)
      FileUtils.mkdir_p(out_dir)
    end

    out_name = out_dir + "/#{store_code}-restock-#{start_date.strftime('%Y%m%d')}-#{end_date.strftime('%Y%m%d')}.xls"
    book.write out_name

    puts "\tSending #{out_name}"
    ReturnsMailer.generic_report(['dave@shipoffers.com','doug@shipoffers.com','shawn@shipoffers.com'],store_code,"#{the_company.name} - Restock Report",out_name).deliver




    return

    puts "Running Report For #{the_date} thru #{end_date}"
    info_regex = Regexp.new('([0-9]{1,2})\s([A-Za-z]*)',Regexp::EXTENDED)
    the_date.upto(end_date).each do |d|
      restock_list = {}
      #restock_list['GA'] = 0
      #restock_list['GC'] = 0
      #restock_list['KE'] = 0
      #restock_list['LT'] = 0
      #restock_list['SA'] = 0
      #restock_list['AQ'] = 0
      #restock_list['HE'] = 0
      #restock_list['SD'] = 0
      #restock_list['TB'] = 0
      #restock_list['CC'] = 0
      #restock_list['CCD'] = 0
      restock_list['total'] = 0
      rtn_count = 0
      ClientShipmentReturn.where(:returned_on=>d).where("ship_station_store_id in (?)",store_list).each do |rtn|
        1.upto(20).each do |cntr|
          sku = rtn.send("sku_#{'%02d' % cntr}") rescue nil
          qty = rtn.send("restock_#{'%02d' % cntr}").to_i
          if sku.nil? || sku.empty?
            break
          end
          if all_skus[sku].nil?
            all_skus[sku] = 1
          end
          restock_list[sku] ||= 0
          restock_list[sku] += qty
          restock_list['total'] ||= 0
          restock_list['total'] += qty.to_i

          rtn_count += 1

        end
        #rtn.resaleable.scan(info_regex) do |qty,sabbrv|
        #  puts "#{sabbrv} x #{qty}"
        #  sabbrv = sabbrv.strip.upcase
        #  if sabbrv == 'HE'
        #    sabbrv = 'HY'
        #  elsif sabbrv == 'KE'
        #    sabbrv = 'RE'
        #  elsif sabbrv == 'AMP'
        #    sabbrv = 'TB'#
        #
        #  end
        #  restock_list[sabbrv] ||= 0
        #  restock_list[sabbrv] += qty.to_i

        #end
      end
      day_list << {'the_date'=>d,'rtn_count' => rtn_count, 'restock_list' => restock_list}
    end


    pp day_list;
    book = Spreadsheet::Workbook.new
    csv = book.create_worksheet :name=>"Restock"
    cntr = 0

    skus = ReturnSku.where("code in (?)",all_skus.keys).map{|m| {:code=>m.code, :name=>m.name}; }
    titles = ['Date']
    titles  << 'Returns'
    skus.each{|s| titles << s[:name];}
    #titles << 'Total'
    csv.row(cntr).replace titles
    day_list.each do |d|
      cntr = cntr + 1
      data = []
      data << d['the_date']
      data << d['rtn_count']
      skus.each{|s| v=d['restock_list'][s[:code]]; (v.nil? == true) ? data << 0 : data << v;}
      # data << d['restock_list']['total']
      csv.row(cntr).replace data
    end

    out_dir = File.expand_path("external_files/cch-restock")
    if Dir.exists?(out_dir) == false
      FileUtils.mkdir_p(out_dir)
    end

    out_name = out_dir + "/#{storeid}-restock-#{the_date.strftime('%Y%m%d')}-#{end_date.strftime('%Y%m%d')}.xls"
    book.write out_name

    ReturnsMailer.generic_report(['shawn@eyefive.com'],store_code,"#{the_store.store_name} - Restock Report",out_name).deliver_now


  end



end