# -*- coding: utf-8 -*-
require 'rainbow'

module MC
  module GUI
    class Mapper
      attr_reader :world

      def initialize(world)
        @world = world
      end

      def print(io, position, width, height)
        floor = Array.new(height) { Array.new(width) }

        height.times do |x|
          width.times do |z|
            floor[x][z] = map_char(position.x.to_i - height / 2 + x - 1,
                                   position.y.to_i,
                                   position.z.to_i - width / 2 + z)
          end
        end

        floor[height / 2][width / 2] = 'X'.color(:red)

        floor.each do |col|
          io.puts(col.reverse.join)
        end
      end


      BlockChars = {
        :rock => " _XX\"\"##",
        :liquid => ' _~~""##',
        :torch => ' .ii``::',
        :door => '|-',
        :tree => ' .oo∘∘OO',
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

        case block.type
        when 0 then ' '
        when 1, 53, 67, 108, 109, 114 then BlockChars[:rock][solid_index].color(:default)
        when 2 then BlockChars[:rock][solid_index].color(:green)
        when 3 then BlockChars[:rock][solid_index].color(255, 64, 0)
        when 7 then BlockChars[:rock][solid_index].color(64, 64, 64)
        when 8, 9 then BlockChars[:liquid][solid_index].color(:blue)
        when 10, 11 then BlockChars[:liquid][solid_index].color(:red)
        when 12 then BlockChars[:rock][solid_index].color(:yellow)
        when 17 then BlockChars[:tree][solid_index].color(128, 64, 0)
        when 18 then BlockChars[:rock][solid_index].color(0, 128, 0)
        when 50 then BlockChars[:torch][solid_index].color(:yellow)
        when 64 then BlockChars[:door][0]
        when 71 then BlockChars[:door][0]
        else BlockChars[:rock][solid_index].color(96, 96, 96)
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
