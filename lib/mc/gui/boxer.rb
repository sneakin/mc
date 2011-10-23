module MC
  module GUI
    class Boxer
      attr_reader :column, :row, :terminal

      def initialize(terminal, column, row)
        @terminal = terminal
        @column = column
        @row = row
        @cursor_y = 0
        @cursor_x = 0
      end

      def move_cursor_to(column, row)
        @cursor_x = column
        @cursor_y = row
        self
      end

      def puts(str)
        str.to_s.split("\n").each { |line|
          write(line)
          @cursor_y += 1
          @cursor_x = 0
        }

        self
      end

      def write(str)
        terminal.move_cursor_to(@column + @cursor_x, @row + @cursor_y)
        terminal.write(str)
        @cursor_x += str.length
        self
      end
    end
  end
end
