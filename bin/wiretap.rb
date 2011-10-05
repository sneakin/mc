require 'socket'

s = TCPServer.new(25565)

begin
  client = s.accept

  remote = TCPSocket.new('li172-212.members.linode.com', 25565)

  begin
    i, o, e = IO.select([remote, client], [remote, client], [], 10)

    if i.include?(remote)
      data = remote.recv(1024)
      client.write(data) if data.size > 0
    end

    if i.include?(client)
      data = client.recv(1024)
      if data.size > 0
        puts "#{Time.now}\t#{data.inspect}"
        remote.write(data)
      end
    end
  end until client.closed? || remote.closed?
end while true
