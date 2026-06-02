class AddPhoneToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :phone, :string
  end
end
