class GameState < ApplicationRecord
  belongs_to :winner_faction, class_name: "Faction", optional: true

  def self.current
    first_or_create(running: true)
  end

  def self.running?
    current.running?
  end

  def self.stop!(winner)
    current.update!(running: false, winner_faction: winner)
  end

  def self.reset!
    current.update!(running: true, winner_faction: nil)
  end
end
