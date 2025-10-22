class WorldTickService
  def self.tick!
    new.tick!
  end

  def tick!
    puts "[World Tick] Starting tick at #{Time.current}"

    # Step 1: Resolve combat (push off outnumbered players)
    resolve_combat

    # Step 2: Update territory control based on remaining players
    update_territory_control

    # Step 3: Move bots
    move_bots

    # Step 4: Update faction totals
    update_faction_power

    puts "[World Tick] Tick complete"
  end

  private

  def resolve_combat
    respawned_count = 0
    Territory.joins(:player_positions).distinct.find_each do |territory|
      faction_counts = territory.players_by_faction.transform_values(&:count)
      next if faction_counts.size <= 1 # No combat if only one faction present

      # Find dominant faction (most players)
      dominant_faction, dominant_count = faction_counts.max_by { |_, count| count }

      # Push off players from other factions if outnumbered 2:1 or more
      territory.players.each do |player|
        next if player.faction == dominant_faction

        outnumbered_count = faction_counts[player.faction] || 0
        if dominant_count >= outnumbered_count * 2
          respawn_player(player)
          respawned_count += 1
        end
      end
    end
    puts "[World Tick] Respawned #{respawned_count} outnumbered players"
  end

  def respawn_player(player)
    # Find respawn territory: controlled rally point or faction corner
    respawn_territory = find_respawn_territory(player.faction)
    player.move_to!(respawn_territory) if respawn_territory
  end

  def find_respawn_territory(faction)
    # First: Try to find a controlled rally point
    rally_spawn = Territory.where(is_rally_point: true, faction: faction).first
    return rally_spawn if rally_spawn

    # Fallback: Faction's corner (Red: top-left, Blue: bottom-right)
    if faction.name == "Red"
      Territory.find_by(x: 0, y: 0)
    else # Blue
      Territory.find_by(x: 9, y: 19)
    end
  end

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
