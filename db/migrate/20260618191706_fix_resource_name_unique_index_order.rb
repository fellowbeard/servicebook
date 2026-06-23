class FixResourceNameUniqueIndexOrder < ActiveRecord::Migration[8.0]
  def change
    remove_index :resources, name: "index_resources_on_account_id_and_name"

    add_index :resources,
              [:name, :account_id],
              unique: true,
              name: "index_resources_on_name_and_account_id"
  end
end
