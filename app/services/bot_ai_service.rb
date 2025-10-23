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

    # Build weighted list based on:
    # - Rally points get weight 2
    # - Regular tiles get weight 1
    # - Tiles we just came from get weight 0 (never go back)
    # - Tiles with 3+ friendly bots get weight 0 (spread out!)
    weighted_choices = []

    adjacent.each do |territory|
      # Never return to the tile we just came from
      next if @bot.last_territory_id && territory.id == @bot.last_territory_id

      # Count friendly bots already on this tile
      friendly_count = territory.players.count { |p| p.faction_id == @bot.faction_id }

      # Don't move to tiles with 3+ friendly bots already (spread out!)
      next if friendly_count >= 3

      # Rally points get 2x weight
      weight = territory.is_rally_point? ? 2 : 1

      # Add territory to choices based on weight
      weight.times { weighted_choices << territory }
    end

    # If all adjacent tiles are blocked, pick any adjacent tile at random
    if weighted_choices.empty?
      target = adjacent.sample
    else
      target = weighted_choices.sample
    end

    # Update last territory before moving
    @bot.update_column(:last_territory_id, current_pos.id)
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

    # Find territories that match the (x,y) coordinate pairs
    adjacent_coords.map { |ax, ay| Territory.find_by(x: ax, y: ay) }.compact
  end
end
