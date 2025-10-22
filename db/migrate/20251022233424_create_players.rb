class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :faction, null: false, foreign_key: true
      t.string :name
      t.boolean :is_bot
      t.integer :resources
      t.integer :power_level
      t.datetime :last_active_at

      t.timestamps
    end
  end
end
