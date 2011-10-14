# -*- coding: utf-8 -*-
module MC
  class PathFinder
    Infinity = 1.0 / 0

    class Square
      attr_accessor :parent, :position, :g, :h, :steps

      def initialize(parent, position, g, h, steps = 0)
        self.parent = parent
        self.position = position
        self.g = g
        self.h = h
        self.steps = steps
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
      @position = vector.try(:to_block_position)
    end

    def target=(vector)
      @target = vector.try(:to_block_position)
    end

    def at_target?(point = position)
      target == nil || point == target
    end

    def map_updated_at(position)
    end

    def plot(max_steps = 100)
      raise ArgumentError.new("Unwalkable target: #{target}") unless walkable?(target)

      @open = [ Square.new(nil, position, 0, estimated_cost_from(position)) ]
      @closed = Array.new

      while !open.empty?
        current = open.shift
        break if !loaded?(current.position)
        closed << current
        break if at_target?(current.position) || current.steps > max_steps

        neighbors_of(current.position) do |pos|
          next if closed.find { |e| e.position == pos }

          g = current.g + cost_to_move(current.position, pos)
          next if g == Infinity

          if (square = open.find { |e| e.position == pos })
            if g < square.g
              square.parent = current
              square.g = g
              square.steps = current.steps + 1
            end
          else
            open << Square.new(current, pos, g, estimated_cost_from(pos), current.steps + 1)
          end
        end

        open.sort! { |a, b| a.f <=> b.f }
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
      [ -1, 0, 1 ].each do |dy|
        [ -1, 0, 1 ].each do |dz|
          [ -1, 0, 1 ].each do |dx|
            next if dz == 0 && dx == 0 && dy != -1
            yield(point + Vector.new(dx, dy, dz))
          end
        end
      end
    end

    def loaded?(point)
      @world[point.x, point.y, point.z].loaded?
    end

    def solid?(point)
      @world[point.x, point.y, point.z].type != 0
    end

    def walkable?(point)
      return true if !loaded?(point - Vector.new(0, -1, 0))
      solid?(point + Vector.new(0, -1, 0)) &&
        !solid?(point) &&
        !solid?(point + Vector.new(0, 1, 0))
    end

    # Returns true if `b`, the destination, is not walkable, or if `a` to `b`
    # is a diagonal and there is a solid block to the side, above, or below `a`,
    # or if a->b is downward and there's a block above b at headlevel.
    def blocked_from?(a, b)
      delta = b - a
      !walkable?(b) || ((delta.x.abs == 1 && delta.z.abs == 1) && (!walkable?(a + Vector.new(delta.x, 0, 0)) || !walkable?(a + Vector.new(0, 0, delta.z)))) || (delta.y == -1 && solid?(b + Vector.new(0, 2, 0)))
    end

    def cost_to_move(a, b)
      if blocked_from?(a, b)
        Infinity
      else
        delta = b - a

        # Approximate delta.length * 10
        if delta.x.abs == 1 && delta.y.abs == 1 && delta.z.abs == 1
          17
        elsif delta.x.abs == 1 && delta.z.abs == 1
          14
        else
          10
        end
      end
    end

    def trace_path(closed)
      path = Array.new
      p = closed.last
      while p && p.parent
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

      min_x = grid.min { |a, b| a.position.x <=> b.position.x }.position.x.to_i - 1
      min_y = grid.min { |a, b| a.position.y <=> b.position.y }.position.y.to_i - 1
      min_z = grid.min { |a, b| a.position.z <=> b.position.z }.position.z.to_i - 1
      max_x = grid.max { |a, b| a.position.x <=> b.position.x }.position.x.to_i + 1
      max_y = grid.max { |a, b| a.position.y <=> b.position.y }.position.y.to_i + 1
      max_z = grid.max { |a, b| a.position.z <=> b.position.z }.position.z.to_i + 1


      MC.logger.debug("#{desc}: #{min_x} #{min_y} #{min_z}\t#{max_x} #{max_y} #{max_z}")
      str = ""
      min_y.upto(max_y) do |y|
        min_z.upto(max_z) do |z|
          min_x.upto(max_x) do |x|
            p = Vector.new(x, y, z)
            square = grid.find { |s| s.position == p }
            #p.y = square.position.y if square

            i = if p == @position
                  "*"
                elsif p == @target
                  'T'
                else
                  "_"
                end
            up = '_'
            if square && square.parent
              up = case (square.parent.position - p).y
                   when 1 then 'U'
                   when 0 then ' '
                   when -1 then 'D'
                   else '_'
                   end
            end

            if square
              g = square.g.to_i rescue 9999
              str += ("%s%s%s %4i %4i  " % [ i, direction_char(p, square.parent.try(:position)), up, g, square.h ])
            else
              str += ("%s__  ____ ____  " % [ i ])
            end
          end
          str += ("\n")
        end
        str += "-------\n"
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
