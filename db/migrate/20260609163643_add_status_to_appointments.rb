class AddStatusToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :status, :string, null: false, default: "scheduled"
  end
end
