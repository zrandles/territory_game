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

    # Pick a random adjacent tile
    target = adjacent.sample

    # Move to it
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
