# Clear existing data
PlayerPosition.destroy_all
Action.destroy_all
Player.destroy_all
Territory.destroy_all
Faction.destroy_all
GameState.destroy_all

puts "Creating factions..."
red_faction = Faction.create!(name: "Red", color: "#ef4444", total_power: 0)
blue_faction = Faction.create!(name: "Blue", color: "#3b82f6", total_power: 0)

puts "Creating 10x20 grid of territories..."
rally_points = [
  {x: 5, y: 5},   # Top center rally point
  {x: 5, y: 10},  # Middle center rally point (most contested)
  {x: 5, y: 15}   # Bottom center rally point
]

(0..9).each do |x|
  (0..19).each do |y|
    is_rally = rally_points.any? { |rp| rp[:x] == x && rp[:y] == y }
    Territory.create!(
      x: x,
      y: y,
      faction: nil,
      player_count: 0,
      is_rally_point: is_rally
    )
  end
end

puts "Creating 20 players (1 human + 19 bots)..."
# Create human player
human = Player.create!(
  faction: red_faction,
  name: "You",
  is_bot: false,
  resources: 100,
  power_level: 1,
  last_active_at: Time.current
)

# Create 9 red bots
(1..9).each do |i|
  Player.create!(
    faction: red_faction,
    name: "Red Bot #{i}",
    is_bot: true,
    resources: 100,
    power_level: 1,
    last_active_at: Time.current
  )
end

# Create 10 blue bots
(1..10).each do |i|
  Player.create!(
    faction: blue_faction,
    name: "Blue Bot #{i}",
    is_bot: true,
    resources: 100,
    power_level: 1,
    last_active_at: Time.current
  )
end

puts "Placing players randomly on map..."
Player.all.each do |player|
  # Place each player at a random position
  territory = Territory.order("RANDOM()").first
  player.move_to!(territory)
end

puts "Initializing game state..."
GameState.create!(running: true, winner_faction: nil)

puts "✅ Seed complete!"
puts "  - 2 Factions (Red, Blue)"
puts "  - 20 Players (1 human, 19 bots)"
puts "  - 200 Territories (10x20 grid)"
puts "  - 3 Rally Points (vertical center line: y=5, y=10, y=15)"
puts "  - All players placed randomly"
puts "  - Game running!"
