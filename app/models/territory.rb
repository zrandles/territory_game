class Territory < ApplicationRecord
  belongs_to :faction, optional: true
  has_many :player_positions
  has_many :players, through: :player_positions

  scope :rally_points, -> { where(is_rally_point: true) }

  def adjacent_to?(other_territory)
    return false unless other_territory
    (x - other_territory.x).abs + (y - other_territory.y).abs == 1
  end

  def players_by_faction
    player_positions.includes(:player).group_by { |pp| pp.player.faction }
  end

  def update_control!
    faction_counts = players_by_faction.transform_values(&:count)

    if faction_counts.empty?
      # No players on this territory - make it neutral
      update!(faction: nil, player_count: 0) if faction_id.present? || player_count > 0
      return
    end

    winning_faction, count = faction_counts.max_by { |_, count| count }
    update!(faction: winning_faction, player_count: count)
  end

  # Rally points are worth 3x in territory control calculations
  def territory_value
    is_rally_point? ? 3 : 1
  end
end
