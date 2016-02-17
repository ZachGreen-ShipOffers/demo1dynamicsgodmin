class ShipOffersAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject)
    # return true
    # Rails.logger.debug("Action is #{action} Subject is #{subject}") if subject.is_a?(String)
    # Rails.logger.debug("Action is #{action} Subject is #{subject.to_s} [class]") if subject.is_a?(Class)
    # Rails.logger.debug("Action is #{action} Subject is #{subject.class.name} [instance]") if !subject.is_a?(Class) && !subject.is_a?(String)

    if subject.is_a?(User)
      Rails.logger.debug subject.awesome_inspect
    end

    if user.admin?
      return true
    else

      return false if action == :delete
      return false if action == :create
      return false if action == :update

      if !subject.is_a?(Class) && !subject.is_a?(String)
        case subject.class.name
        when 'Client::Product'
          return true
        when 'Client::Sku'
            return true if action == :update
        when 'Client::Order'
          return true
        when 'ShipStationShipment'
          return true if action == :read
          return false
        when 'ShipStationOrder'
          return true if action == :read
          return false
        end
      end

      if subject.is_a?(Class)
        return false if subject.to_s == 'ClientCompany'
        return false if subject.to_s == 'ReturnReasonCode'
        return false if subject.to_s == 'ReturnSku'
        return false if subject.to_s == 'User'
        return true
      end

      if subject.is_a?(User)
        return true if subject.id == user.id
        return false
      end


      if subject.is_a?(String)
        case subject
          when 'Shipment'
            return true if action == :view
          when 'Order'
            return true if action == :view
          when 'ClientReturn'
            return true if action == :view
          when 'User'
            return true if action == :view
            return true if action == :update
          else
            return false
        end
      else
        case subject
          when ActiveAdmin::Page
            Rails.logger.debug "I am checking a page: #{subject.name}"
            return false if subject.name == 'Clients'
            return false if subject.name == 'ReturnCode'
            return false if subject.name == 'ReturnSku'
        else
          if subject.is_a?(User)
            return true if subject.id == user.id && (action == :view || action == :update )
          elsif action == :view
            return true
          elsif action == :read && (subject.is_a?(ShipStationShipment) || subject.is_a?(ShipStationOrder) || subject.is_a?(ClientShipmentReturn))
          elsif action == :read && subject.class.to_s == 'Class'
            return true
          else
            return false
          end
        end
      end
    end
=begin
    case subject
      when normalized(Shipment)
        if action == :view
          true
        elsif user.admin?
          true
        else
          false
        end
      when normalized(ShipmentReturn)
        if action == :view
          true
        elsif user.admin?
          true
        else
          false
        end
      else
        user.admin?
    end
=end
    true
  end
end
