class Territory < ApplicationRecord
  belongs_to :faction, optional: true
  has_many :player_positions
  has_many :players, through: :player_positions

  def adjacent_to?(other_territory)
    return false unless other_territory
    (x - other_territory.x).abs + (y - other_territory.y).abs == 1
  end

  def players_by_faction
    player_positions.includes(:player).group_by { |pp| pp.player.faction }
  end

  def update_control!
    faction_counts = players_by_faction.transform_values(&:count)
    return if faction_counts.empty?

    winning_faction, count = faction_counts.max_by { |_, count| count }
    update!(faction: winning_faction, player_count: count)
  end
end
