class AddLastTerritoryIdToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :last_territory_id, :integer
  end
end
