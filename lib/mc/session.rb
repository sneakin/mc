require 'net/https'

module MC
  class Session
    attr_reader :version, :ticket, :user_name, :session_id

    def initialize(nick, password)
      http = https_to("https://login.minecraft.net/")

      req = Net::HTTP::Post.new("/")
      req.set_form_data({ :user => nick, :password => password, :version => Version })
      res = http.request(req)
      @version, @ticket, @user_name, @session_id = res.body.rstrip.split(':')
    end

    def join_server(server_hash)
      http = Net::HTTP.new("session.minecraft.net")
      req = Net::HTTP::Get.new("/game/joinserver.jsp?user=#{user_name}&sessionId=#{session_id}&serverId=#{server_hash}")
      res = http.request(req)
    end

    def https_to(uri)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end
  end
end
