class MakeScheduledAtNotNullOnAppointments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :appointments, :scheduled_at, false
  end
end
