class NotificationRecipient < ActiveRecord::Base
  belongs_to :client, class_name: 'ClientCompany', foreign_key: 'client_company_id'
end
