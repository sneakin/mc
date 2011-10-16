module MC
  class MobData < Struct.new(:name, :char)
    def to_s; name; end
  end

  Mobs = Hash.new("Unknown")
  <<-EOT.split("\n").each { |l| tid, name, char = l.split(/\s+/); Mobs[tid.to_i] = MobData.new(name, char) }
50	 Creeper       C
51	 Skeleton      K
52	 Spider        8
53	 Giant Zombie  Z
54	 Zombie        z
55	 Slime         s
56	 Ghast         G
57	 Zombie Pigman P
58	 Enderman      E
59	 Cave Spider   &
60	 Silverfish    f
61	 Blaze         B
62	 Magma Cube    *
90	 Pig           p
91	 Sheep         b
92	 Cow           c
93	 Hen           h
94	 Squid         q
95	 Wolf          W
97	 Snowman       n
120	 Villager      V
-1       Player        @
EOT
end
