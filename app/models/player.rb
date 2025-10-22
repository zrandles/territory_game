class Player < ApplicationRecord
  belongs_to :faction
  has_one :player_position
  has_one :current_territory, through: :player_position, source: :territory
  has_many :actions

  def move_to!(territory)
    if player_position
      player_position.update!(territory: territory)
    else
      create_player_position!(territory: territory)
    end
  end

  def current_position
    player_position&.territory
  end
end
