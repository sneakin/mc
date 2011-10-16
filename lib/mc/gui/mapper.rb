# -*- coding: utf-8 -*-
require 'rainbow'

module MC
  module GUI
    class Mapper
      attr_reader :world

      def initialize(world)
        @world = world
      end

      def print(io, position, width, height, entities)
        floor = Array.new(height) { Array.new(width) }

        min = Vector.new(position.x.to_i - height / 2,
                         position.y - 2,
                         position.z.to_i - width / 2)
        max = min + Vector.new(height, position.y + 3, width)

        height.times do |x|
          width.times do |z|
            floor[x][z] = map_char(min.x + x - 1,
                                   position.y.to_i,
                                   min.z + z)
          end
        end

        entities.select { |ent|
          ent.position >= min && ent.position < max
        }.each do |ent|
          p = (ent.position - position).clamp
          floor[p.x + height / 2][p.z + width / 2] = '@'.color(:red)
        end

        floor[height / 2][width / 2] = 'X'.color(:red)

        floor.each do |col|
          io.puts(col.reverse.join)
        end
      end


      BlockChars = {
        :rock => " ∙⩓⩓⩔⩔  ",
        :liquid => ' ~⩓⩓⩔⩔  ',
        :torch => ' •ii``::',
        :door => '|-',
        :tree => ' •oo∘∘OO',
      }

      def map_char(x, y, z)
        legs = world[x, y, z]
        return '?'.color(64, 64, 64) unless legs.loaded?

        feet = world[x, y - 1, z]
        head = world[x, y + 1, z]
        #above = world[x, y + 2, z]

        block = feet
        block = legs if legs.solid?
        block = head if head.solid?

        solid_index = (feet.solid? ? 1 : 0) | (legs.solid? ? 1 : 0) << 1 | (head.solid? ? 1 : 0) << 2
        MC.logger.debug("#{legs.inspect}\n#{feet.inspect}\n#{head.inspect}\n#{solid_index}")

        c = case block.type
            when 0 then ' '
            when 1, 53, 67, 108, 109, 114 then BlockChars[:rock][solid_index]
            when 2 then BlockChars[:rock][solid_index]
            when 3 then BlockChars[:rock][solid_index]
            when 7 then BlockChars[:rock][solid_index]
            when 8, 9 then BlockChars[:liquid][solid_index]
            when 10, 11 then BlockChars[:liquid][solid_index]
            when 12 then BlockChars[:rock][solid_index]
            when 17 then BlockChars[:tree][solid_index]
            when 18 then BlockChars[:rock][solid_index]
            when 50 then BlockChars[:torch][solid_index]
            when 64 then BlockChars[:door][0]
            when 71 then BlockChars[:door][0]
            else BlockChars[:rock][solid_index]
            end

        if head.solid? && legs.solid?
          c.color(:default).background(*block_color(head.type))
        else
          c.color(*block_color(block.type))
        end
      end

      def block_color(type)
        case type
        when 0 then :black
        when 1, 53, 67, 108, 109, 114 then [ 128, 128, 128 ]
        when 2 then :green
        when 3 then [ 255, 64, 0 ]
        when 7 then [ 64, 64, 64 ]
        when 8, 9 then :blue
        when 10, 11 then :red
        when 12 then :yellow
        when 17 then [ 128, 64, 0 ]
        when 18 then [ 0, 128, 0 ]
        when 50 then :yellow
        when 64 then :yellow
        when 71 then :yellow
        else [ 96, 96, 96 ]
        end
      end

      def block_char(block)
        return '?'.color(64, 64, 64) unless block.loaded?

        case block.type
        when 0 then ' '
        when 53 then '>'
        when 67 then '>'
        when 108 then '>'
        when 109 then '>'
        when 114 then '>'
        else '#'
        end
      end
    end
  end
end
