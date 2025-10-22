class MakeTerritoryFactionOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :territories, :faction_id, true
  end
end
