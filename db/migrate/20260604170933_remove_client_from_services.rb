class RemoveClientFromServices < ActiveRecord::Migration[8.1]
  def change
    remove_reference :services, :client, null: false, foreign_key: true
  end
end
