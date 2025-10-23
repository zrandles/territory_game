class CreateGameStates < ActiveRecord::Migration[8.0]
  def change
    create_table :game_states do |t|
      t.boolean :running
      t.integer :winner_faction_id

      t.timestamps
    end
  end
end
