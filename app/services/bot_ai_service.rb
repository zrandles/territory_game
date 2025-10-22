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
    target = adjacent.min_by do |territory|
      score = evaluate_territory(territory)
      score
    end

    @bot.move_to!(target) if target
  end

  def evaluate_territory(territory)
    enemy_count = territory.players.count { |p| p.faction_id != @bot.faction_id }
    friendly_count = territory.players.count { |p| p.faction_id == @bot.faction_id }

    # Start with enemy count as base score (lower is better)
    score = enemy_count

    # HUGE bonus for uncaptured rally points
    if territory.is_rally_point && territory.faction_id != @bot.faction_id
      score -= 200
    end

    # Bonus for defending our rally points
    if territory.is_rally_point && territory.faction_id == @bot.faction_id
      score -= 50
    end

    # Prefer neutral or friendly territories
    if territory.faction_id.nil? || territory.faction_id == @bot.faction_id
      score -= 30
    end

    # Avoid tiles where we're heavily outnumbered (2:1 push-off threshold)
    if enemy_count >= 2 * (friendly_count + 1) # +1 for this bot
      score += 100 # Heavy penalty for walking into push-off
    end

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

    Territory.where(x: adjacent_coords.map(&:first), y: adjacent_coords.map(&:last))
  end
end
