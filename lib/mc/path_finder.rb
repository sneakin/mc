# -*- coding: utf-8 -*-
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

    def initialize(world, starting, target)
      @world = world
      @closed = Array.new
      @open = Array.new
      @position = starting
      @target = target
    end

    attr_reader :closed, :open, :position, :target

    def position=(vector)
      @position = vector
    end

    def target=(vector)
      @target = vector
    end

    def at_target?
      target == nil || position == target
    end

    def map_updated_at(position)
    end

    def plot
      return Array.new unless walkable?(position) && walkable?(target)

      @open = [ Square.new(nil, position, 0, estimated_cost_from(position)) ]
      @closed = Array.new

      while !open.empty?
        current = open.shift
        closed << current
        break if current.position == target

        neighbors_of(current.position) do |pos|
          next if blocked_from?(current.position, pos) || closed.find { |e| e.position == pos }

          g = current.g + cost_to_move(current.position, pos)

          if (square = open.find { |e| e.position == pos })
            if g < square.g
              square.parent = current
              square.g = g
            end
          else
            open << Square.new(current, pos, g, estimated_cost_from(pos))
          end

          open.sort! { |a, b| a.f <=> b.f }
        end
      end

      if ENV['DEBUG']
        debug_dump(open, "Open")
        debug_dump(closed, "Closed")
        debug_dump(open + closed, "Both")
      end

      trace_path(closed)
    end

    def estimated_cost_from(point)
      point.distance_to(target) * 10
    end

    def neighbors_of(point)
      [ -1, 0, 1 ].each do |dz|
        [ -1, 0, 1 ].each do |dx|
          next if dz == 0 && dx == 0
          yield((point + Vector.new(dx, 0, dz)).clamp)
        end
      end
    end

    def walkable?(point)
      block = @world[point.x.to_i, point.y.to_i, point.z.to_i]
      block.type == 0
    rescue
      false
    end

    # Returns true if `b`, the destination, is not walkable or if `a` to `b`
    # is a diagonal and there is a solid block to the side, above, or below `a`.
    def blocked_from?(a, b)
      delta = b - a
      !walkable?(b) || ((delta.x.abs == 1 && delta.z.abs == 1) && (!walkable?(a + Vector.new(delta.x, 0, 0)) || !walkable?(a + Vector.new(0, 0, delta.z))))
    end

    def cost_to_move(a, b)
      delta = b - a
      if delta.x.abs == 1 && delta.z.abs == 1
        14
      else
        10
      end
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

    def debug_dump(grid, desc = "Closed")
      if grid.empty?
        MC.logger.debug("#{desc}: empty")
        return
      end

      min_x = grid.min { |a, b| a.position.x <=> b.position.x }.position.x - 1
      min_z = grid.min { |a, b| a.position.z <=> b.position.z }.position.z - 1
      max_x = grid.max { |a, b| a.position.x <=> b.position.x }.position.x + 1
      max_z = grid.max { |a, b| a.position.z <=> b.position.z }.position.z + 1


      MC.logger.debug("#{desc}: #{min_x} #{min_z}\t#{max_x} #{max_z}")
      str = ""
      min_z.upto(max_z) do |z|
        min_x.upto(max_x) do |x|
          p = Vector.new(x, position.y, z)
          square = grid.find { |s| s.position.x == x && s.position.z == z }
          p.y = square.position.y if square

          i = if p == @position
                "*"
              elsif p == @target
                'T'
              else
                "_"
              end

          if square
            str += ("%s%s %4i %4i  " % [ i, direction_char(p, square.parent.try(:position)), square.g, square.h ])
          else
            str += ("%s  ____ ____  " % [ i ])
          end
        end
        str += ("\n")
      end
      MC.logger.debug("\n#{str}")
    end

    DirArrows = [ [ '↖', '↑', '↗'],
                  [ '⟵', '*', '⟶'],
                  [ '↙', '↓', '↘']
                ]
    def direction_char(a, b)
      return 'N' if a.nil? || b.nil?

      d = b - a
      DirArrows[d.z + 1][d.x + 1]
    end
  end
end
