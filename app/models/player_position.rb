class PlayerPosition < ApplicationRecord
  belongs_to :player
  belongs_to :territory
end
