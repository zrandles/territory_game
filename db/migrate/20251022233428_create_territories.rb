class CreateTerritories < ActiveRecord::Migration[8.0]
  def change
    create_table :territories do |t|
      t.integer :x
      t.integer :y
      t.references :faction, null: true, foreign_key: true
      t.integer :player_count

      t.timestamps
    end
  end
end
