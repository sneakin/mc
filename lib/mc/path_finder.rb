module MC
  class PathFinder
    class Square
      attr_accessor :parent, :position, :g, :h

      def initialize(parent, position, g, h)
        self.parent = parent
        self.position = position
        self.g = g
        self.h = h
      end

      def f
        g + h
      end
    end

    def initialize(world)
      @world = world
      @closed = Array.new
      @open = Array.new
    end

    attr_reader :closed, :open, :position, :target

    def position=(vector)
      @position = vector
    end

    def target=(vector)
      @target = vector
    end

    def at_target?
      position == target
    end

    def map_updated_at(position)
    end

    def plot
      return Array.new unless walkable?(position) && walkable?(target)

      @open = [ Square.new(nil, position, 0, position.distance_to(target) * 10) ]
      @closed = Array.new

      while !open.empty?
        current = open.shift
        closed << current
        break if current.position == target

        neighbors_of(current.position) do |pos, block|
          next if !walkable?(pos) || closed.find { |e| e.position == pos }
          # don't cut corners
          delta = pos - current.position
          next if (delta.x.abs == 1 && delta.z.abs == 1) && (!walkable?(current.position + Vector.new(delta.x, 0, 0)) || !walkable?(current.position + Vector.new(0, 0, delta.z)))

          weight = 10
          weight = 14 if delta.x.abs == 1 && delta.z.abs == 1
          g = current.g + weight

          if (square = open.find { |e| e.position == pos })
            if g < square.g
              square.parent = current
              square.g = g
            end
          else
            open << Square.new(current, pos, g, pos.distance_to(target) * 10)
          end

          open.sort! { |a, b| a.f <=> b.f }
        end
      end

      #closed_debug_dump(closed)

      trace_path(closed)
    end

    def neighbors_of(point)
      x = point.x.to_i
      y = point.y.to_i
      z = point.z.to_i

      [ -1, 0, 1 ].each do |dz|
        [ -1, 0, 1 ].each do |dx|
          next if dz == 0 && dx == 0

          block = @world[x + dx, y, z + dz] rescue nil
          yield(Vector.new(x + dx, y, z + dz), block)
        end
      end
    end

    def walkable?(point)
      block = @world[point.x.to_i, point.y.to_i, point.z.to_i]
      block.type == 0
    rescue
      false
    end

    def trace_path(closed)
      path = Array.new
      p = closed.last
      while p.parent
        path.unshift(p.position)
        p = p.parent
      end
      path
    end

    private

    def closed_debug_dump(closed)
      min_x = closed.min { |a, b| a.position.x <=> b.position.x }.position.x - 1
      min_z = closed.min { |a, b| a.position.z <=> b.position.z }.position.z - 1
      max_x = closed.max { |a, b| a.position.x <=> b.position.x }.position.x + 1
      max_z = closed.max { |a, b| a.position.z <=> b.position.z }.position.z + 1


      MC.logger.debug("Closed: #{min_x} #{min_z}\t#{max_x} #{max_z}")
      str = ""
      (max_z - min_z).to_i.times do |z|
        (max_x - min_x).to_i.times do |x|
          square = closed.find { |s| s.position.x == (min_x + x) && s.position.z == (min_z + z) }
          if square
            str += ("%4i %4i  " % [ square.g, square.h ])
          else
            str += ("____ ____  ")
          end
        end
        str += ("\n")
      end
      MC.logger.debug("\n#{str}")
    end
  end
end
