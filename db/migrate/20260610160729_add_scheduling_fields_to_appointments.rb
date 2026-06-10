class AddSchedulingFieldsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :appointments, :account, foreign_key: true
    add_reference :appointments, :user, foreign_key: true
    add_reference :appointments, :resource, foreign_key: true
  end
end
