class AddUserToClients < ActiveRecord::Migration[8.1]
  def change
    add_reference :clients, :user, null: true, foreign_key: true
  end
end
