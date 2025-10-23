class BotAiService
  def self.make_move(bot)
    new(bot).make_move
  end

  def initialize(bot)
    @bot = bot
  end

  def make_move
    current_pos = @bot.current_position
    return unless current_pos

    # Get adjacent territories
    adjacent = find_adjacent_territories(current_pos)
    return if adjacent.empty?

    # Strategy: Prioritize rally points, avoid overwhelming enemy forces
    # Add some randomness to avoid oscillating behavior
    scored_territories = adjacent.map do |territory|
      base_score = evaluate_territory(territory)
      # Add small random factor to break ties and add variety
      random_factor = rand(-5..5)
      [territory, base_score + random_factor]
    end

    target = scored_territories.min_by { |_, score| score }.first

    @bot.move_to!(target) if target
  end

  def evaluate_territory(territory)
    enemy_count = territory.players.count { |p| p.faction_id != @bot.faction_id }
    friendly_count = territory.players.count { |p| p.faction_id == @bot.faction_id }

    # Start with base score of 0
    score = 0

    # HUGE bonus for uncaptured rally points
    if territory.is_rally_point && territory.faction_id != @bot.faction_id
      score -= 300  # Increased from 200
    end

    # MASSIVE bonus for enemy rally points (attack them!)
    if territory.is_rally_point && territory.faction_id && territory.faction_id != @bot.faction_id
      score -= 250  # New: prioritize attacking enemy rally points
    end

    # Medium bonus for defending our rally points (but not camping)
    if territory.is_rally_point && territory.faction_id == @bot.faction_id
      score -= 30  # Reduced from 50 - don't camp as much
    end

    # Strong preference for neutral territories (expand!)
    if territory.faction_id.nil?
      score -= 40  # New: capture neutral ground
    end

    # Slight preference for enemy territories (be aggressive!)
    if territory.faction_id && territory.faction_id != @bot.faction_id && !territory.is_rally_point
      score -= 20  # New: attack enemy territories
    end

    # Penalize staying on already-friendly territories (spread out!)
    if territory.faction_id == @bot.faction_id && !territory.is_rally_point
      score += 15  # New: discourage clustering
    end

    # Penalize tiles with too many friendlies already (spread out!)
    if friendly_count >= 2
      score += 25 * friendly_count  # Stack penalty - encourage spreading
    end

    # Avoid tiles where we're heavily outnumbered (2:1 push-off threshold)
    if enemy_count >= 2 * (friendly_count + 1) # +1 for this bot
      score += 150  # Increased penalty
    end

    # Small penalty for enemy presence to create caution
    score += enemy_count * 5

    score
  end

  private

  def find_adjacent_territories(territory)
    x, y = territory.x, territory.y

    adjacent_coords = [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
    ].select { |ax, ay| ax.between?(0, 9) && ay.between?(0, 19) }

    # Find territories that match the (x,y) coordinate pairs
    adjacent_coords.map { |ax, ay| Territory.find_by(x: ax, y: ay) }.compact
  end
end
