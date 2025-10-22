class CreateFactions < ActiveRecord::Migration[8.0]
  def change
    create_table :factions do |t|
      t.string :name
      t.string :color
      t.integer :total_power

      t.timestamps
    end
  end
end
