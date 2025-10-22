class WorldTickJob < ApplicationJob
  queue_as :default

  def perform
    WorldTickService.tick!
  end
end
