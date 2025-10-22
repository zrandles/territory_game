class AddRallyPointToTerritories < ActiveRecord::Migration[8.0]
  def change
    add_column :territories, :is_rally_point, :boolean, default: false, null: false
  end
end
