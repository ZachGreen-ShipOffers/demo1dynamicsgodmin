class ClientShipmentReturn < ActiveRecord::Base


  belongs_to :store, :class_name=>"ShipStationStore", :foreign_key => :ship_station_store_id
  belongs_to :order, :class_name=>"ShipStationOrder", :foreign_key => :ship_station_order_id
  belongs_to :reason_code, :class_name=>"ReturnReasonCode", :foreign_key => 'reason', :primary_key => 'code'
  attr_reader :items



  def title
    "#{self.order.order_number} - #{self.customer}" rescue self.customer
  end

  def store_name
    (self.store.nil? == false) ? self.store.store_name : ''
  end

  def original_order_numbers
    if self.order.nil?
      "------"
    else
      self.order.order_number
    end
  end

  def original_items
    ''
    #if self.order.nil?
    #  ""
    #else
    #  if self.order.items.length > 0
    #    self.order.items.collect {|i|  (i.sku.nil? || i.sku.empty?) ? "#{i.description} x #{i.quantity}" : "#{i.sku} x #{i.quantity}"}.join("\n")
    #  else
    #    ""
    #  end
    #end
  end

  def items
    items = []
    1.upto(10).each do |i|
      sfld = "sku_#{'%02d' % i}"
      r1fld = "returned_#{'%02d' % i}"
      r2fld = "restock_#{'%02d' % i}"
      r3fld = "damagaed_#{'%02d' % i}"
      sku = self.send(sfld).strip.upcase rescue nil
      break if sku.nil? || sku.empty?
      sku = ReturnSku.where(:code=>sku).first.name rescue sku
      returned = self[r1fld].to_i rescue 0
      restock = self[r2fld].to_i rescue 0
      damaged = self[r3fld].to_i rescue 0
      items << { :sku=>sku, :returned=>returned, :restocked=>restock, :damagaed => damaged}
    end
    items
  end

  def self.as_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |item|
          csv << item.attributes.values_at(*column_names)
        end
     end
  end

end