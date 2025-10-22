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

    # Simple strategy: Move to adjacent territory with fewest enemy players
    target = adjacent.min_by do |territory|
      enemy_count = territory.players.count { |p| p.faction_id != @bot.faction_id }
      # Prefer neutral or same-faction territories
      if territory.faction_id.nil? || territory.faction_id == @bot.faction_id
        enemy_count - 100  # Heavy preference
      else
        enemy_count
      end
    end

    @bot.move_to!(target) if target
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
