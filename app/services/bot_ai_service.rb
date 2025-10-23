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

    # Never stay on the same square for 2 ticks
    # Filter out current position if we were just here
    if @bot.last_territory_id == current_pos.id
      adjacent = adjacent.reject { |t| t.id == current_pos.id }
      return if adjacent.empty?
    end

    # Build weighted list: each territory gets weight of 1
    # If there's a rally point next door, give it weight of 2
    weighted_choices = []

    adjacent.each do |territory|
      # Check if this territory is a rally point
      weight = territory.is_rally_point? ? 2 : 1

      # Add territory to choices based on weight
      weight.times { weighted_choices << territory }
    end

    # Pick random territory from weighted list
    target = weighted_choices.sample

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
