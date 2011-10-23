module MC
  autoload :Vector, 'mc/vector'

  module Spec
    module Helpers
      def self.included(base)
        base.extend(self)
      end

      def v(*args)
        MC::Vector.new(*args)
      end
    end
  end
end
