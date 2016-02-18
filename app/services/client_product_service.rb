class ClientProductService
  include Godmin::Resources::ResourceService

  def resource_class
    Client::Product
  end

  attrs_for_index *Client::Product.column_names
  attrs_for_show *Client::Product.column_names
  attrs_for_form
end
