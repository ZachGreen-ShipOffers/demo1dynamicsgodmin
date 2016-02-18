class Export
  require './lib/dynamics_helper.rb'
  @@date_fmt = '%m/%d/%y'.freeze
  @@ship_kind = 'FULFILLMENT'.freeze
  attr_accessor :cpny

  def initialize(cpny,sd,ed='')
    @cpny = ClientCompany.where(dyna_code: cpny).first
    @start_date = Date.parse(sd) rescue Date.today
    @end_date = Date.parse(sd) rescue Date.today
  end

  def shipment_count
    if @start_date == @end_date
      count = @cpny.shipments.where("ship_station_shipments.ship_date = ?", @start_date).count.to_s
    else
      count = @cpny.shipments.where("ship_station_shipments.ship_date between ? and ?", @start_date, @end_date).count
    end
    return count.to_s
  end

  def export
    # LIVE
    @dyna_send = 'SHPO'
    # QA
    # @dyna_send = 'QASHP'
    # TEST
    # @dyna_send = 'TSHPO'

    puts "#{@cpny.dyna_code} => #{@start_date} <=> #{@end_date}"

    if @start_date == @end_date
      process(@start_date)
    else
      date = @start_date
      while date < @end_date do
        count = process(date)
        date = date.next
      end
    end
    # send_email(@ids,sd,ed,cpny_code) if @email
    return count
  end
  # handle_asynchronously :export

  private
  def process(date)
    helper = DynamicsHelper::ShipmentHelper.getClientFromCode(@cpny.dyna_code)

    csv = open_csv
    shipments = @cpny.shipments.where("ship_station_shipments.ship_date = ? and voided = false", date)
    order_count = 0
    ap "Found #{shipments.count} Shipments(s) for #{@cpny.dyna_code}"
    shipments.each do |s|
      next if s.nil?
      next if s.items.nil? || s.items.length < 1
      next if s.voided
      order_count = order_count + 1
      #process shipments
      build_csv(helper, csv, s)
    end

    ap "Exported #{order_count} Shipments(s) for #{@cpny.dyna_code}"
    di = DynamicsInfo.find_or_create_by(client_company_id: @cpny.id, ship_count: order_count, date: @start_date, export_file: csv.path)
    send_csv(csv, order_count, @ftp)
    return order_count
  end

  def build_csv(helper, csv, shipment)
    item_count = add_items(helper, csv, shipment)
    add_packtype(helper, csv, shipment, item_count)
    add_shiptype(helper, csv, shipment, item_count)
  end

  def add_items(helper, csv, s)
    item_count = 0

    s.items.each do |k,v|

      item_info = helper.mapsku(s,k['sku'],k['quantity'])
      next if item_info[:sku] == "NULL"
      if item_info[:sku].is_a? Array
        for i in 0..item_info[:sku].length-1 do
          item_count = item_count + item_info[:quantity][i]
          csv << [
          s.id,
          (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code),
          s.ship_date.to_time.utc.strftime(@@date_fmt),
          'Shipped',
          s.name,
          s.street1,
          s.street2,
          s.city,
          s.state,
          s.postal_code,
          s.country,
          s.tracking_number,
          s.order_number,
          s.service_code,
          is_reshipment?(s),
          is_billable?(s),
          @@ship_kind,
          item_info[:sku][i],
          item_info[:quantity][i],
          'false',
          'false',
          'false',
          'false',
          @dyna_send,
          (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code)]
        end
      else
        item_count = item_count + item_info[:quantity].to_i

        csv << [
        s.id,
        (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code),
        s.ship_date.to_time.utc.strftime(@@date_fmt),
        'Shipped',
        s.name,
        s.street1,
        s.street2,
        s.city,
        s.state,
        s.postal_code,
        s.country,
        s.tracking_number,
        s.order_number,
        s.service_code, #need to write method
        is_reshipment?(s), #need to write method
        is_billable?(s), #need to write method
        @@ship_kind,
        item_info[:sku],
        item_info[:quantity],
        'false',
        'false',
        'false',
        'false',
        @dyna_send,
        (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code)]
      end
    end

    # add fat burn book for 3 or more items
    if item_count >= 3
      if @cpny.dyna_code == 'PER001'
        item_count = item_count + 1
        add_book(csv, s)
      end
    end
    return item_count
  end

  def add_shiptype(helper, csv, s, item_count)
    shipType = helper.shiptype(s, s.items, item_count)
    if !shipType.nil?
      csv << [
      s.id,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code),
      s.ship_date.to_time.utc.strftime(@@date_fmt),
      'Shipped',
      s.name,
      s.street1,
      s.street2,
      s.city,
      s.state,
      s.postal_code,
      s.country,
      s.tracking_number,
      s.order_number,
      s.service_code, #need to write method
      is_reshipment?(s), #need to write method
      is_billable?(s), #need to write method
      @@ship_kind,
      shipType,
      1,
      'false',
      'false',
      'false',
      'false',
      @dyna_send,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code)]
    end
  end

  def add_packtype(helper, csv, s, item_count)
    pkType = helper.packtype(s, s.items, item_count)
    csv << [
      s.id,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code),
      s.ship_date.to_time.utc.strftime(@@date_fmt),
      'Shipped',
      s.name,
      s.street1,
      s.street2,
      s.city,
      s.state,
      s.postal_code,
      s.country,
      s.tracking_number,
      s.order_number,
      s.service_code, #need to write method
      is_reshipment?(s), #need to write method
      is_billable?(s), #need to write method
      @@ship_kind,
      pkType,
      1,
      'false',
      'false',
      'false',
      'false',
      @dyna_send,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code)]
  end

  def is_billable?(s)
    the_order = s.ss_order
    if !the_order.custom_field2.nil? && !the_order.custom_field2.empty?
      if  the_order.custom_field2.include?('RSNB') || the_order.custom_field2.include?('RSB')
        return !the_order.custom_field2.include?('RSNB') ? 'true' : 'false'
      end
      return true
    end
    return true
  end

  def is_reshipment?(s)
    the_order = s.ss_order
    if !the_order.custom_field2.nil? && !the_order.custom_field2.empty?
      if  the_order.custom_field2.include?('RSNB') || the_order.custom_field2.include?('RSB')
        return true
      end
      return false
    end
    return false
  end

  def add_book(csv, s)
    csv << [
      s.id,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code),
      s.ship_date.to_time.utc.strftime(@@date_fmt),
      'Shipped',
      s.name,
      s.street1,
      s.street2,
      s.city,
      s.state,
      s.postal_code,
      s.country,
      s.tracking_number,
      s.order_number,
      s.service_code, #need to write method
      is_reshipment?(s), #need to write method
      is_billable?(s), #need to write method
      @@ship_kind,
      '232-FBBOOK-101',
      1,
      'false',
      'false',
      'false',
      'false',
      @dyna_send,
      (@cpny.dyna_code == 'BLA001' ? 'LEA001' : @cpny.dyna_code)]
  end

  def send_csv(csv, order_total, ftp)
    csv.close
    if order_total < 1
      File.delete(csv.path) if File.exist?(csv.path)
    else
      if ftp == true
        ap "Sending to FTP..."
        Net::FTP.open('dynagp.etrackerplus.com', 'dynamics.dynagp', 'y5VhGmtg') do |ftp|
          ftp.chdir('/Export')
          ftp.put(csv.path)
        end
      end
    end
  end

  def open_csv
    out_dir = File.expand_path("dynaexp/#{@cpny.dyna_code}", './external_files')
    if Dir.exists?(out_dir) == false
      FileUtils.mkdir_p(out_dir)
    end
    dyn_name = "#{out_dir}/shipments-#{cpny.dyna_code}-#{@start_date.strftime('%Y%m%d')}-#{@end_date.strftime('%Y%m%d')}.pro"
    dyn_csv = CSV.open(dyn_name, 'w',{:force_quotes=>true})
    dyn_csv << %w(ShipmentUUID ClientID Date Status ShipToName ShipToAddress1 ShipToAddress2 ShipToCity ShipToState ShipToZIP ShipToCountry TrackingNo OrderNo ShipmentMethod Reshipment Billable Kind CustomerSKU Quantity Kitted Insure SigRequired Delete Company PriceLevel)
    # ap dyn_name
    return dyn_csv
  end

  def send_email(ids,sd,ed, cpny=nil)
    ap "Sending Email..."
    if cpny.nil?
      out_name = "external_files/email/Exports_#{DateTime.now.to_s}.csv"
    else
      out_name = "external_files/email/Exports_#{cpny}_#{DateTime.now.to_s}.csv"
    end
    csv = CSV.open(out_name, 'w+')
    csv << ['Dyna_Code', 'Count', 'Start Date', 'End Date']
    ids.each do |i|
      info = DynamicsInfo.find i
      csv << [info.dyna_code, info.export_count, info.start_date, info.end_date]
    end
    csv.close
    DynamicsMailer.report(@@emails,sd,ed,out_name).deliver_now
  end



end
