module MC
  Mobs = Hash.new("Unknown")
  <<-EOT.split("\n").each { |l| tid, name = l.split(/\s+/); Mobs[tid.to_i] = name }
50	 Creeper
51	 Skeleton
52	 Spider
53	 Giant Zombie
54	 Zombie
55	 Slime
56	 Ghast
57	 Zombie Pigman
58	 Enderman
59	 Cave Spider
60	 Silverfish
61	 Blaze
62	 Magma Cube
90	 Pig
91	 Sheep
92	 Cow
93	 Hen
94	 Squid
95	 Wolf
97	 Snowman
120	 Villager
-1       Player
EOT
end
