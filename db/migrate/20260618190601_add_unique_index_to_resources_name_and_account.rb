class AddUniqueIndexToResourcesNameAndAccount < ActiveRecord::Migration[8.1]
  def change
    add_index :resources, [:account_id, :name], unique: true
  end
end
