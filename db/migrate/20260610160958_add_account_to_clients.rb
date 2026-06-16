class AddAccountToClients < ActiveRecord::Migration[8.1]
  def change
    add_reference :clients, :account, foreign_key: true
  end
end
