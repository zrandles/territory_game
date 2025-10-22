class WorldTickService
  def self.tick!
    new.tick!
  end

  def tick!
    puts "[World Tick] Starting tick at #{Time.current}"

    # Step 1: Update territory control based on player positions
    update_territory_control

    # Step 2: Move bots
    move_bots

    # Step 3: Update faction totals
    update_faction_power

    puts "[World Tick] Tick complete"
  end

  private

  def update_territory_control
    Territory.find_each do |territory|
      territory.update_control!
    end
    puts "[World Tick] Updated territory control"
  end

  def move_bots
    bot_count = 0
    Player.where(is_bot: true).find_each do |bot|
      BotAiService.make_move(bot)
      bot_count += 1
    end
    puts "[World Tick] Moved #{bot_count} bots"
  end

  def update_faction_power
    Faction.find_each do |faction|
      faction.update_total_power!
    end
    puts "[World Tick] Updated faction power totals"
  end
end
