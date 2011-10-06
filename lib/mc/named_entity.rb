module MC
  autoload :Entity, 'mc/entity'

  class NamedEntity < Entity
    attr_accessor :name, :current_item

    def named?
      true
    end
  end
end
