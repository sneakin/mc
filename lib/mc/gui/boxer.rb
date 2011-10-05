module MC
  module GUI
    class Boxer
      def initialize(column, row)
        @column = column
        @row = row
        @line = 0
      end

      def puts(str)
        str.split("\n").each { |line|
          write(line + "\n")
          @line += 1
        }

        self
      end

      def write(str)
        $stdout.write("\033[#{@row + @line};#{@column}H#{str}")
        self
      end
    end
  end
end
