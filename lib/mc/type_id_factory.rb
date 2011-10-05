require 'active_support/core_ext'

module MC
  module TypeIdFactory
    def self.included(base)
      base.instance_eval <<-EOT
        Factory = TypeIdFactory::Worker.new

        def types
          Factory.types
        end

        def register(id)
          Factory.register(id, self)
        end

        def create(id)
          Factory.create(id)
        end
      EOT
    end

    class Worker
      def types
        @types ||= Hash.new { |h, key| raise "Bad type id: %#x" % [ key ] }
      end

      def register(id, klass)
        types[id] = klass
      end

      def create(type_id)
        types[type_id].new
      end
    end
  end
end
