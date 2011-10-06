module MC
  class ServerInfo
    attr_accessor :max_players, :mode, :difficulty
    attr_reader :players

    def initialize
      @max_players = 0
      @mode = 0
      @difficulty = 0
      @players = Hash.new
    end

    def update(packet)
      self.max_players = packet.max_players
      self.mode = packet.server_mode
      self.difficulty = packet.difficulty
    end

    def update_player(name, online, ping)
      if online
        players[name] = ping
      else
        players.delete(name)
      end
    end
  end
end
