require 'termios'

module MC
  module GUI
    class Terminal
      Columns = `tput cols`.to_i
      Lines = `tput lines`.to_i

      attr_reader :io, :width, :height

      def initialize(io = $stdout, width = Columns.to_i, height = Lines)
        @io = io
        @width = width
        @height = height
      end

      def write(str)
        @io.write(str)
      end

      def reset
        move_cursor_to(0, 0)
        clear
      end

      def escape(str)
        @io.write("\033[#{str}")
      end

      def box(column, row, &block)
        boxer = GUI::Boxer.new(self, column, row)
        block.call(boxer)
      end

      def character_mode
        t = Termios.tcgetattr($stdin)
        t.lflag &= ~Termios::ICANON
        Termios.tcsetattr($stdin, 0, t)
      end

      def line_mode
        t = Termios.tcgetattr($stdin)
        t.lflag |= Termios::ICANON
        Termios.tcsetattr($stdin, 0, t)
      end

      def move_cursor_to(column, row)
        escape("#{row};#{column}f")
      end

      def echo(yes)
        t = Termios.tcgetattr($stdin)

        if yes
          t.lflag |= Termios::ECHO
        else
          t.lflag &= ~Termios::ECHO
        end

        Termios.tcsetattr($stdin, 0, t)
      end

      def clear
        escape("2J")
      end

      def clear_left
        escape("1K")
      end

      def clear_right
        escape("0K")
      end
    end
  end
end
