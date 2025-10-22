class Faction < ApplicationRecord
  has_many :players
  has_many :territories
  has_many :player_positions, through: :players

  def update_total_power!
    update(total_power: territories.count)
  end
end
