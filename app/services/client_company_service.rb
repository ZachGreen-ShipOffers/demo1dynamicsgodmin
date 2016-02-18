class ClientCompanyService
  include Godmin::Resources::ResourceService

  attrs_for_index :dyna_code, :name, :run_export
  attrs_for_show :dyna_code, :name, :run_export
  attrs_for_form :dyna_code, :name, :run_export

  # def find_resource(id)
  #   resources_relation.find_by(id: id)
  # end
end
