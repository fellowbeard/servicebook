class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.references :account, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
