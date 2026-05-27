class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :title
      t.decimal :price
      t.integer :duration_minutes
      t.text :description

      t.timestamps
    end
  end
end
