class GameController < ApplicationController
  def index
    @human_player = Player.find_by(is_bot: false)
    @territories = Territory.includes(:faction, :players).order(:y, :x)
    @factions = Faction.all
  end

  def move
    @human_player = Player.find_by(is_bot: false)
    target_territory = Territory.find_by(x: params[:x], y: params[:y])

    if target_territory
      current_pos = @human_player.current_position

      if current_pos.nil? || current_pos.adjacent_to?(target_territory)
        # Store old position before moving
        old_territory = current_pos

        # Move player
        @human_player.move_to!(target_territory)

        # Update territory control immediately for both territories
        old_territory.update_control! if old_territory
        target_territory.update_control!

        flash[:notice] = "Moved to (#{target_territory.x}, #{target_territory.y})"
      else
        flash[:alert] = "Can only move to adjacent territories!"
      end
    end

    redirect_to root_path
  end

  def restart
    # Reset game state
    GameState.reset!

    # Re-seed the database
    require_relative "../../db/seeds"

    flash[:notice] = "Game restarted! Good luck!"
    redirect_to root_path
  end
end
