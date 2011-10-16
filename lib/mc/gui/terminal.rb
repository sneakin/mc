module MC
  module GUI
    class Terminal
      Columns = `tput cols`.to_i
      Lines = `tput lines`.to_i

      attr_reader :io, :width, :height, :cursor_x, :cursor_y

      def initialize(io = $stdout, width = Columns.to_i, height = Lines)
        @io = io
        @width = width
        @height = height
        @cursor_x = 0
        @curser_y = 0

        reset
      end

      def reset
        move_cursor_to(0, 0)
        clear
      end

      def escape(str)
        @io.write("\033[#{str}")
      end

      def box(column, row, &block)
        boxer = GUI::Boxer.new(column, row)
        block.call(boxer)
      end

      def move_cursor_to(column, row)
        escape("#{column};#{row}f")
        @cursor_x = column
        @cursor_y = row
      end

      def clear
        escape("2J")
      end

      def clear_left
        escape("1K")
      end
    end
  end
end
