class CreateDynamicsInfos < ActiveRecord::Migration
  def change
    create_table :dynamics_infos do |t|
      t.uuid :client_company_id
      t.integer :ship_count
      t.date :date
      t.string :export_file
    end
    add_foreign_key :dynamics_infos, :client_companies
  end
end
