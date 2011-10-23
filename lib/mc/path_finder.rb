# -*- coding: utf-8 -*-
module MC
  class PathFinder
    MaxSteps = 96
    Infinity = 1.0 / 0

    class InvalidPathError < RuntimeError
    end

    class NotEnoughStepsError < InvalidPathError
    end

    class InvalidTargetError < RuntimeError
    end

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
      self.target = target
      self.position = starting
    end

    attr_reader :closed, :open, :position, :target

    def position=(vector)
      p = vector.try(:to_block_position)
      @position_changed = position != p
      @position = p
    end

    def target=(vector)
      p = vector.try(:to_block_position)
      @target_changed = target != p
      @target = p
    end

    def at_target?(point = position)
      target == nil || point == target
    end

    def map_updated_at(position)

    end

    def reset!
      @open = [ Square.new(nil, position, 0, estimated_cost_from(position)) ]
      @closed = Array.new
      @target_changed = @position_changed = false
    end

    def plot(max_steps = MaxSteps)
      raise InvalidTargetError.new("Already at the target.") if at_target?
      raise InvalidTargetError.new("Target (#{target}) is bed rock.") if block_at(target).bed_rock?
      #MC.logger.debug("Plotting #{position} -> #{target}")

      reset! if @target_changed || @position_changed

      s = 0
      while !open.empty?
        s += 1
        current = open.shift
        break if s >= max_steps
        closed << current
        break if at_target?(current.position)

        neighbors_of(current.position) do |pos|
          next if closed.find { |e| e.position == pos }

          g = current.g + cost_to_move(current.position, pos)
          next if g == Infinity

          if (square = open.find { |e| e.position == pos })
            if g < square.g
              square.parent = current
              square.g = g
            end
          else
            open << Square.new(current, pos, g, estimated_cost_from(pos))
          end
        end

        open.sort! { |a, b| a.f <=> b.f }
      end

#       if ENV['DEBUG']
#         debug_dump(open, "Open")
#         debug_dump(closed, "Closed")
#         debug_dump(open + closed, "Both")
#       end

      trace_path(closed)
    end

    def estimated_cost_from(point)
      (target - point).length_square
    end

    def neighbors_of(point)
      [ -1, 0, 1 ].each do |dy|
        [ -1, 0, 1 ].each do |dz|
          [ -1, 0, 1 ].each do |dx|
            yield(point + Vector.new(dx, dy, dz))
          end
        end
      end
    end

    def block_at(point)
      @world[point.x, point.y, point.z]
    end

    def loaded?(point)
      block_at(point).loaded?
    end

    def solid?(point)
      block_at(point).solid?
    end

    def cost_to_clear(point)
      c = 0
      legs = @world[point.x, point.y, point.z]
      c += legs.strength if legs.solid?
      head = @world[point.x, point.y + 1, point.z]
      c += head.strength if head.solid?
      c
    end

    def neighboring_water?(point, direction)
      block_at(point + Vector.new(0, 0, direction.z)).liquid? ||
        block_at(point + Vector.new(0, 1, direction.z)).liquid? ||
        block_at(point + Vector.new(direction.x, 0, 0)).liquid? ||
        block_at(point + Vector.new(direction.x, 1, 0)).liquid?
    end

    def cost_to_move(a, b)
      return Infinity if !loaded?(b)

      delta = b - a
      c = 1

      return Infinity if neighboring_water?(b, delta)

      c += cost_to_clear(b)
      if delta.x.abs > 0 && delta.z.abs > 0
        c += cost_to_clear(a + Vector.new(delta.x, 0, 0))
        c += cost_to_clear(a + Vector.new(0, 0, delta.z))
        if delta.y.abs > 0
          c += cost_to_clear(a + Vector.new(delta.x, delta.y, 0))
          c += cost_to_clear(a + Vector.new(0, delta.y, delta.z))
        end
      end

      if delta.y >= 0 && !solid?(b + Vector.new(0, -1, 0))
        c = Infinity
      end

      if delta.y > 0
        c += block_at(a + Vector.new(0, 2, 0)).strength
      elsif delta.y < 0
        c += block_at(b + Vector.new(0, 2, 0)).strength

        if !solid?(b + Vector.new(0, -1, 0)) # jumping off
          c += 1000
        end
      end

      c * 10
    end

    def trace_path(closed)
      p = if at_target?(closed.last.position)
            closed.last
          else
            closed.min { |a, b| a.h <=> b.h }
          end
      path = Array.new

      while p && p.parent
        path.unshift(p.position)
        p = p.parent
      end

      raise InvalidPathError.new("There is no valid path.") if path.empty?
      raise NotEnoughStepsError.new("More steps are required") if position.distance_to(path[0]) > 1.8

      path.unshift(position)
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
