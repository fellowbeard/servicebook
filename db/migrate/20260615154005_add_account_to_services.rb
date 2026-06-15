class AddAccountToServices < ActiveRecord::Migration[8.1]
  def change
    add_reference :services, :account, null: false, foreign_key: true
  end
end
