class Faction < ApplicationRecord
  has_many :players
  has_many :territories
  has_many :player_positions, through: :players

  def update_total_power!
    # Calculate total territory value (rally points worth 3x)
    total = territories.sum { |t| t.territory_value }
    update(total_power: total)
  end

  def control_percentage
    total_territory_value = Territory.sum { |t| t.territory_value }
    return 0 if total_territory_value == 0
    (total_power.to_f / total_territory_value * 100).round(1)
  end

  def winning?
    control_percentage >= 60.0
  end
end
