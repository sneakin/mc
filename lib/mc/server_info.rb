module MC
  class ServerInfo
    attr_accessor :max_players, :mode, :difficulty

    def initialize
      @max_players = 0
      @mode = 0
      @difficulty = 0
    end

    def update(packet)
      self.max_players = packet.max_players
      self.mode = packet.server_mode
      self.difficulty = packet.difficulty
    end
  end
end
