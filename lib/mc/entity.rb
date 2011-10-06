module MC
  class Entity
    attr_accessor :entity_id, :position, :velocity, :meta_data, :pitch, :yaw, :mob_type, :equipment

    def initialize
      self.equipment = Hash.new
    end

    delegate :x, :y, :z, :to => :position

    def named?
      false
    end

    def equip(slot, item_id, damage = 0)
      if item_id == -1
        equipment.delete(slot)
      else
        equipment[slot] = [ item_id, damage ]
      end
    end
  end
end
