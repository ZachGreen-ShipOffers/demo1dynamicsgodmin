require 'rest-client'
require 'base64'
require 'awesome_print'
require 'json'

class ShipStationSync < Thor



    SS_ENDPOINT = 'https://ssapi.shipstation.com'.freeze


  ShipStationSync.desc "import_services CARRIER_CODE", "Update Database with a list of services for CARRIER_CODE from ship station"
  def import_services(carrier_code)
    require './config/environment' # Load Rails Stuff
    puts "Importing services list for carrier code #{carrier_code} from ship station"

    config = load_config

    done = false
    the_page = 1

    while !done
      begin
        res = get_services({
                               'api_key' => config['ss']['api_key'],
                               'api_secret' => config['ss']['api_secret'],
                               'carrier' => carrier_code
                           })


        if res['code'].to_i == 200
          services = res['data']
          if services.is_a?(Array)
            services.each do |service|
              ap service
            end
          end
          done = true
        else
          done = true
          ap res
        end

      rescue Exception => e
        done = true
        puts e.message
      end

    end
  end


  ShipStationSync.desc "import_carriers", "Update Database with a list of carriers from ship station"
  def import_carriers()
    require './config/environment' # Load Rails Stuff
    puts "Importing carriers list from ship station"

    config = load_config

    done = false
    the_page = 1

    while !done
      begin
        res = get_carriers({
                             'api_key' => config['ss']['api_key'],
                             'api_secret' => config['ss']['api_secret']
                         })


        if res['code'].to_i == 200
          carriers = res['data']
          if carriers.is_a?(Array)
            carriers.each do |carrier|
             ap carrier
            end
          end
          done = true
        else
          done = true
          ap res
        end

      rescue Exception => e
        done = true
        puts e.message
      end

    end
  end



    ShipStationSync.desc "import_store_list", "Update Database with a list of stores from ship station"
    def import_store_list()
      require './config/environment' # Load Rails Stuff
      puts "Importing store list from ship station"

      config = load_config

      done = false
      the_page = 1

      no_clients = []

      while !done
        begin
          res = get_stores({
                               'api_key' => config['ss']['api_key'],
                               'api_secret' => config['ss']['api_secret'],
                               'showInactive' => 'true'
                           })


          if res['code'].to_i == 200
            stores = res['data']
            if stores.is_a?(Array)
              stores.each do |store|
                puts "\tImporting: #{store['storeId']}\t#{store['storeName']}"
                db_store = ShipStationStore.find(store['storeId'].to_i) rescue ShipStationStore.new
                if db_store.new_record?
                  db_store[:id] = store['storeId']
                end
                db_store.store_name = store['storeName']
                db_store.company_name = store['companyName']
                db_store.marketplace_id = store["marketplaceId"]
                db_store.marketplace_name = store["marketplaceName"]
                db_store.active = store['active']
                db_store.save!
                dyna_code = /^[A-Z]{3,3}[0-9]{3,3}/.match(db_store.store_name)[0] rescue nil
                if !dyna_code.nil?
                  the_client = ClientCompany.find_by(dyna_code: dyna_code)
                  if the_client.nil?
                    puts "\t No Client for #{db_store.store_name}"
                    no_clients << db_store.store_name
                  else
                    # We found the client, so make sure this store is associated with them
                    db_store.client_company_id = the_client.id
                    db_store.save!
                  end
                end

              end
            end
            done = true
          else
            done = true
            ap res
          end

        rescue Exception => e
          done = true
          puts e.message
        end

        puts "no clients for these stores"
        ap no_clients
      end
    end

    ShipStationSync.desc "import_shipments START_DATE END_DATE *STORES","Import Shipments From START_DATE until END_DATE"
    def import_shipments(start_date,end_date)
      require './config/environment' # Load Rails Stuff
      config = load_config

      api_key = config['ss']['api_key'].freeze
      api_secret = config['ss']['api_secret'].freeze

      start_date = start_date.to_date rescue Date.today
      end_date = end_date.to_date rescue Date.today

      # @todo Wrap this in a loop that checks void date as well otherwise we will miss shipments
      base_ss_params = {
          'api_key' => api_key,
          'api_secret' => api_secret,
          'shipDateStart' => start_date.strftime('%F'),
          'shipDateEnd' => end_date.strftime('%F'),
          'includeShipmentItems' => 'true',
          'pageSize' => 500
      }

      catch (:stopme) do
        begin

            done = false
            page = 1
            error_count = 0

            until done == true
              order_params = {}
              order_params['page'] = page

              res = get_shipments(base_ss_params.merge(order_params))

              if res['code'].to_i == 200
                error_count = 0
                result = res['data']
                shipments = result.delete('shipments')
                if !shipments.nil? && shipments.length > 0
                  shipments.each do |ss|
                    puts "\t Syncing: #{ss['shipmentId']}\t#{ss['trackingNumber']}"
                    ns = create_or_update_shipment(ss)

                    the_order = ShipStationOrder.find_by(id: ns.ship_station_order_id)
                    # For now only copy order details from orders which already exists
                    # @todo Add a thor task which trys to update order details from shipments with no orders
                    if !the_order.nil?
                      puts "\t\tUpdating Store ID"
                      ns.ship_station_store_id = the_order.ship_station_store_id
                      ns.email = the_order.email
                    end
                    ns.save!
                    puts "\t\tSaved #{ss['shipmentId']}"
                  end
                else
                  done = true
                end
                page += 1
              else
                done = true
                puts "Could Not Update Shipments"
                ap res
              end
            end



        rescue Exception => e
          puts 'I got an exception:'
          puts e.message
          puts e.backtrace.join("\n")
          throw :stopme
        end

      end

    end


    ShipStationSync.desc "import_orders START_DATE END_DATE *STORE_IDS", "Import Orders from START_DATE to END_DATE (modifyDate is used to retrieve the orders)"
    def import_orders(start_date, end_date, *restrict_to)
      require './config/environment' # Load Rails Stuff



      config = load_config
      api_key = config['ss']['api_key'].freeze
      api_secret = config['ss']['api_secret'].freeze

      start_date = start_date.to_date rescue Date.today
      end_date = end_date.to_date rescue Date.today

      # build list of store id's for the api
      store_list = []
      output = []
      if !restrict_to.nil? && !restrict_to.empty?
        restrict_to.each do |restricted|
          if is_number?(restricted)
            store_list << restricted
          else
            # must be a string code for our dynamics id's
            # store_list += ShipStation::Store.where(dyna_code: restricted.to_s.upcase).pluck(:id)
            ClientCompany.where(dyna_code: restricted.to_s.upcase).each do |s|
              s.stores.each do |t|
                store_list << t.id
                output << [t.store_name, t.id]
              end
            end
          end
        end
      else
        store_list = ShipStationStore.where(active: true).pluck(:id)
        output = ShipStationStore.where(active: true).pluck(:store_name, :id)
        #store_list = ['*']
      end

      puts "I am doing these stores"
      # ap store_list
      output.each do |s|
        ap "Name: #{s[0]}id: #{s[1]}"
      end


      base_ss_params = {
          'api_key' => api_key,
          'api_secret' => api_secret,
          'modifyDateStart' => start_date.strftime('%F 00:00:00'),
          'modifyDateEnd' => end_date.strftime('%F 23:59:59'),
          'pageSize' => 500
      }


      catch (:stopme) do
        begin
          store_list.each do |store|
            puts "Processing #{store}"
            done = false
            page = 1
            error_count = 0
            while !done
              order_params = {}
              order_params['page'] = page
              order_params['storeId'] = store unless store == '*'
              res = get_orders(base_ss_params.merge(order_params))

              if res['code'] == 200
                error_count = 0
                result = res['data']
                orders = result.delete('orders')
                unless orders.nil? || orders.length < 1
                  orders.each do |ss|
                    puts "\t Syncing: #{ss['orderId']}\t#{ss['createDate']}\t#{ss['shipTo']['name']}"
                    create_or_update_order(ss)
                  end
                end



                page += 1
                done = true if (result['total'] < 500) || result['pages'] < page
              else
                done = true
                puts "Could Not Update Orders: #{res.code} was recevied"
              end
            end

          end

        rescue Exception => e
          puts 'I got an exception:'
          puts e.message
          puts e.backtrace.join("\n")
          throw :stopme
        end

      end

    end

  ShipStationSync.desc "import_all START_DATE END_DATE", "Import All Records from START_DATE to END_DATE (modifyDate is used to retrieve the orders)"
  def import_all(start_date, end_date)
    require './config/environment' # Load Rails Stuff
    sdate = start_date.to_date
    edate = end_date.to_date

    puts "Processing Stores"
    ShipStationSync.new.invoke 'ship_station_sync:import_store_list'

    puts "Processing #{sdate.strftime('%F')} thru #{edate.strftime('%F')}"
    sdate.upto(edate) do |the_date|
        puts "\t-- syncing #{the_date.strftime('%F')}"
        ShipStationSync.new.invoke 'ship_station_sync:import_orders',[the_date.strftime('%F'),the_date.strftime('%F')]
        ShipStationSync.new.invoke 'ship_station_sync:import_shipments',[the_date.strftime('%F'),the_date.strftime('%F')]
    end

  end


  no_commands do

      def create_or_update_order(ss)
        nwo = ShipStationOrder.find_or_initialize_by(id: ss['orderId'])
        if nwo.new_record?
          nwo[:id] = ss['orderId']
        end
        nwo.order_number = ss['orderNumber']
        nwo.ship_station_store_id = ss['advancedOptions']['storeId']
        nwo.order_key = ss['orderKey']
        nwo.order_status = ss['orderStatus']
        nwo.email = ss['customerEmail']
        nwo.name = ss['shipTo']['name']
        nwo.company = ss['shipTo']['company']
        nwo.street1 = ss['shipTo']['street1']
        nwo.street2 = ss['shipTo']['street2'] unless (ss['shipTo']['street2'].nil? || ss['shipTo']['street2'].empty?)
        nwo.street3 = ss['shipTo']['street3']
        nwo.city = ss['shipTo']['city']
        nwo.state = ss['shipTo']['state']
        nwo.postal_code = ss['shipTo']['postalCode']
        nwo.country = ss['shipTo']['country']
        nwo.phone = ss['shipTo']['phone']
        nwo.items = ss['items']
        nwo.residential = ss['shipTo']['residential']
        nwo.address_verified = ss['shipTo']['addressVerified']
        nwo.carrier_code = ss['carrierCode']
        nwo.package_code = ss['packageCode']
        nwo.service_code = ss['serviceCode']
        nwo.ship_date = ss['shipDate'].to_date rescue nil
        nwo.order_date = ss['orderDate'].to_date rescue nil
        nwo.customer_notes = ss['customerNotes']
        nwo.internal_notes = ss['internalNotes']
        nwo.custom_field1 = ss['advancedOptions']['customField1'].strip.slice(0,255) rescue nil
        nwo.custom_field2 = ss['advancedOptions']['customField2'].strip.slice(0,255) rescue nil
        nwo.custom_field3 = ss['advancedOptions']['customField3'].strip.slice(0,255) rescue nil
        nwo.merged_or_split = ss['advancedOptions']['mergedOrSplit']
        nwo.parent_id = ss['advancedOptions']['parentId']

        nwo.save!
        nwo
      end

      def create_or_update_shipment(ss,ship_station_store_id=nil)
        ns = ShipStationShipment.find_or_initialize_by(id: ss['shipmentId'] )
        ns[:id] = ss['shipmentId'] if ns.new_record?
        ns.ship_station_order_id = ss['orderId']
        ns.order_number = ss['orderNumber']
        ns.ship_date = ss['shipDate'].to_date rescue nil
        ns.tracking_number = ss['trackingNumber']
        ns.batch_number = ss['batchNumber']
        ns.carrier_code = ss['carrierCode']
        ns.package_code = ss['packageCode']
        ns.service_code = ss['serviceCode']
        ns.voided = ss['voided']
        ns.void_date = ss['voidDate'].to_date rescue nil
        ns.return_label = ss['isReturnLabel']
        ns.confirmation = ss['confirmation']
        ns.name = ss['shipTo']['name']
        ns.company = ss['shipTo']['company']
        ns.street1 = ss['shipTo']['street1']
        ns.street2 = ss['shipTo']['street2'] unless (ss['shipTo']['street2'].nil? || ss['shipTo']['street2'].empty?)
        ns.street3 = ss['shipTo']['street3']
        ns.city = ss['shipTo']['city']
        ns.state = ss['shipTo']['state']
        ns.postal_code = ss['shipTo']['postalCode']
        ns.country = ss['shipTo']['country']
        ns.phone = ss['shipTo']['phone']
        ns.items = ss['shipmentItems']
        ns.shipment_cost = ss['shipmentCost']
        ns.insurance_cost = ss['insuranceCost']
        ns.ship_station_store_id = ship_station_store_id
        ns.save!
        ns
      end



      def get_order_details(orderId,api_key,api_secret)
        result = nil
        base_ss_params = {
            'api_key' => api_key,
            'api_secret' => api_secret,
            'order_id' => orderId
        }

        done = false
        while !done
          res = get_order(base_ss_params)


          if res.code == 204 # Good Request But No Results
            done = true
          elsif  res.code == 201
            raise RuntimeError,"WTF? We Didn't create anything???"
            done = true
          elsif res.code == 200
            result = JSON.parse(res.body)
            done = true

          elsif res.code == 429 # rate limit error
            delay_for = res.headers['X-Rate-Limit-Reset'].to_i rescue 30
            puts "rate limit error, sleeping for #{delay_for} seconds"
            sleep(delay_for)
          else
            done = true
            puts "Could Not Update The Order #{orderId}"
            ap res
          end

        end

        result
      end


      def is_number?(obj)
        true if Float(obj) rescue false
      end

      def load_config(cfg = './config/settings.local.yml')
         { 'ss' => {'api_key' => Rails.application.secrets.ss_api_key, 'api_secret' => Rails.application.secrets.ss_api_secret }}
      end

      def extract_from_params(params, ext)
        params[ext]
      end

      def get_order(params)
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        order_id = params.delete("order_id")
        url = "/orders/#{order_id}"
        call_api('get', url, api_key, api_secret)
      end

      def delete_order(params)
        order_id = extract_from_params(params, "order_id")
        url = "/orders/#{order_id}"
        call_api('delete', url, @api_key, @api_secret)
      end

      def get_orders(params={})
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        #url="/orders?" + params.map { |k, v| "#{k}=#{URI::escape(v)}"; }.join('&')
        url = "/orders?" + params.to_query
        call_api('get', url, api_key, api_secret, params)
      end

      def get_shipments(params={})
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        url="/shipments?" + params.to_query
        call_api('get', url, api_key,api_secret, params)
      end

      def get_store(params)
        store_id = extract_from_params(params, "store_id")
        url = "/stores/#{store_id}"
        call_api('get', url, @api_key, @api_secret)
      end

      def get_stores(params={})
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        # params['showInactive'] = 'true'
        url="/stores?" + params.map { |k, v| "#{k}=#{URI::escape(v)}"; }.join('&')
        call_api('get', url, api_key, api_secret)
      end

      def get_marketplaces(params={})
        url = "/stores/marketplaces"
        call_api('get', url, @api_key, @api_secret)
      end

      def get_carriers(params={})
        url = "/carriers"
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        call_api('get', url, api_key, api_secret)
      end

      def get_services(params)
        api_key = params.delete('api_key')
        api_secret = params.delete('api_secret')
        carrier = params.delete("carrier")
        url = "/carriers/listservices?carrierCode=#{carrier}"
        call_api('get', url, api_key, api_secret)
      end

      def call_api(method, url, api_key, api_secret, body=nil)


        full_url = SS_ENDPOINT + url
        auth_info = Base64.strict_encode64(api_key+':'+api_secret)

        headers = {
            'Authorization' => 'Basic '+ auth_info,
            'Content-Type' => 'application/json',
            'Accepts' => 'application/json'

        }


        res = nil
        call_cntr  =  0
        done = false
        result = nil

        begin

          while !done

            # Do the actual code
            if method == 'get'
              res = RestClient.get full_url, headers
            elsif methd == 'delete'
              res = RestClient.delete full_url, headers
            elsif method == 'post'
              res = RestClient.post full_url, body, headers
            end

            # Handle the response
            if res.code == 204 # Good Request But No Results
              done = true
            elsif  res.code == 201
              done = true
            elsif res.code == 200
              result = {  'code' => res.code,
                          'data' => JSON.parse(res.body)
                       }
              done = true
            elsif res.code == 429 # rate limit error
              delay_for = res.headers['X-Rate-Limit-Reset'].to_i rescue 30
              puts "rate limit error, sleeping for #{delay_for} seconds"
              sleep(delay_for)
              call_cntr = call_cntr + 1  # increment the call counter so we can limit how many times we get stuck in a delay loop
            else
              # We got a respose code we were not expecting
              done = true
              result = {
                'code' => res.code,
                'data' => res
              }
            end

          end

        rescue RestClient::Exception => e
          result = { 'code' => 'exception', 'data' => e } # @todo -> what happens with there is no res.code for the other procedure to check????
        end

        result
      end

    end

end
