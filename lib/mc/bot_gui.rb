module MC
  class BotGui
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
    Items = Hash.new("Unknown")
    <<-EOT.split("\n").each { |l| m = l.match(/(\d+)\s+(\w+)\s+(.*)/); Items[$1.to_i] = $3 }
	00	00	Air
	 01	 01	Stone
	02	02	Grass
	 03	 03	Dirt
	 04	 04	Cobblestone
	 05	 05	Wooden Plank
	 06	 06	Sapling
	07	07	Bedrock
	08	08	Water
	09	09	 Stationary water
	10	0A	Lava
	11	0B	 Stationary lava
	 12	 0C	Sand
	 13	 0D	Gravel
	 14	 0E	Gold Ore
	 15	 0F	Iron Ore
	16	10	Coal Ore
	 17	 11	Wood
	 18	 12	Leaves
	19	13	Sponge
	 20	 14	Glass
	21	15	Lapis Lazuli Ore
	 22	 16	Lapis Lazuli Block
	 23	 17	Dispenser
	 24	 18	Sandstone
	 25	 19	Note Block
	26	1A	Bed
	 27	 1B	Powered Rail
	 28	 1C	Detector Rail
	 29	 1D	Sticky Piston
	30	1E	Cobweb
	 31	 1F	Tall Grass
	32	20	Dead Bush
	 33	 21	Piston
	34	22	Piston Extension
	 35	 23	Wool
	36	24	Block moved by Piston
	 37	 25	Dandelion
	 38	 26	Rose
	 39	 27	Brown Mushroom
	 40	 28	Red Mushroom
	 41	 29	Block of Gold
	 42	 2A	Block of Iron
	43	2B	 Double Slabs
	 44	 2C	Slabs
	 45	 2D	Brick Block
	 46	 2E	TNT
	 47	 2F	Bookshelf
	 48	 30	Moss Stone
	 49	 31	Obsidian
	 50	 32	Torch
	51	33	Fire
	52	34	Monster Spawner
	 53	 35	 Wooden Stairs
	 54	 36	Chest
	55	37	Redstone Wire
	56	38	Diamond Ore
	 57	 39	Block of Diamond
	 58	 3A	Crafting Table
	59	3B	Seeds
	60	3C	Farmland
	 61	 3D	Furnace
	62	3E	 Burning Furnace
	63	3F	Sign Post
	64	40	 Wooden Door
	 65	 41	Ladders
	 66	 42	Rails
	 67	 43	 Cobblestone Stairs
	68	44	 Wall Sign
	 69	 45	Lever
	 70	 46	 Stone Pressure Plate
	71	47	 Iron Door
	 72	 48	 Wooden Pressure Plate
	73	49	Redstone Ore
	74	4A	 Glowing Redstone Ore
	75	4B	Redstone Torch ("off" state)
	 76	 4C	Redstone Torch ("on" state)
	 77	 4D	Stone Button
	78	4E	Snow
	79	4F	Ice
	 80	 50	Snow Block
	 81	 51	Cactus
	 82	 52	Clay Block
	83	53	Sugar Cane
	 84	 54	Jukebox
	 85	 55	Fence
	 86	 56	Pumpkin
	 87	 57	Netherrack
	 88	 58	Soul Sand
	 89	 59	Glowstone Block
	90	5A	Portal
	 91	 5B	Jack-O-Lantern
	92	5C	Cake Block
	93	5D	Redstone Repeater ("off" state)
	94	5E	 Redstone Repeater ("on" state)
	95	5F	Locked Chest
	 96	 60	Trapdoor
	97	61	 Hidden Silverfish
	 98	 62	Stone Bricks
	99	63	Huge Brown Mushroom
	100	64	Huge Red Mushroom
	 101	 65	Iron Bars
	 102	 66	Glass Pane
	 103	 67	Melon
	104	68	Pumpkin Stem
	105	69	Melon Stem
	 106	 6A	Vines
	 107	 6B	Fence Gate
	 108	 6C	Brick Stairs
	 109	 6D	Stone Brick Stairs
	110	6E	Mycelium
	 111	 6F	Lily Pad
	 112	 70	Nether Brick
	 113	 71	Nether Brick Fence
	 114	 72	Nether Brick Stairs
	 115	 73	Nether Wart
EOT
    <<-EOT.split("\n").each { |l| m = l.match(/(\d+)\s+(\w+)\s+(.*)/); Items[$1.to_i] = $3 }
	 256	 100	Iron Shovel
	 257	 101	 Iron Pickaxe
	 258	 102	 Iron Axe
	 259	 103	Flint and Steel
	 260	 104	Red Apple
	 261	 105	Bow
	 262	 106	Arrow
	 263	 107	Coal D
	 264	 108	Diamond
	 265	 109	Iron Ingot
	 266	 10A	Gold Ingot
	 267	 10B	 Iron Sword
	 268	 10C	Wooden Sword
	 269	 10D	 Wooden Shovel
	 270	 10E	 Wooden Pickaxe
	 271	 10F	 Wooden Axe
	 272	 110	Stone Sword
	 273	 111	 Stone Shovel
	 274	 112	 Stone Pickaxe
	 275	 113	 Stone Axe
	 276	 114	 Diamond Sword
	 277	 115	 Diamond Shovel
	 278	 116	 Diamond Pickaxe
	 279	 117	 Diamond Axe
	 280	 118	Stick
	 281	 119	Bowl
	 282	 11A	Mushroom Soup
	 283	 11B	Gold Sword
	 284	 11C	 Gold Shovel
	 285	 11D	 Gold Pickaxe
	 286	 11E	 Gold Axe
	 287	 11F	String
	 288	 120	Feather
	 289	 121	Gunpowder
	 290	 122	 Wooden Hoe
	 291	 123	 Stone Hoe
	 292	 124	 Iron Hoe
	 293	 125	 Diamond Hoe
	 294	 126	 Gold Hoe
	 295	 127	Seeds
	 296	 128	Wheat
	 297	 129	Bread
	 298	 12A	Leather Cap
	 299	 12B	 Leather Tunic
	 300	 12C	 Leather Pants
	 301	 12D	 Leather Boots
	302	12E	 Chain Helmet
	303	12F	 Chain Chestplate
	304	130	 Chain Leggings
	305	131	 Chain Boots
	 306	 132	 Iron Helmet
	 307	 133	 Iron Chestplate
	 308	 134	 Iron Leggings
	 309	 135	 Iron Boots
	 310	 136	 Diamond Helmet
	 311	 137	 Diamond Chestplate
	 312	 138	 Diamond Leggings
	 313	 139	 Diamond Boots
	 314	 13A	 Gold Helmet
	 315	 13B	 Gold Chestplate
	 316	 13C	 Gold Leggings
	 317	 13D	 Gold Boots
	 318	 13E	Flint
	 319	 13F	Raw Porkchop
	 320	 140	Cooked Porkchop
	 321	 141	Paintings
	 322	 142	Golden Apple
	 323	 143	Sign
	 324	 144	 Wooden door
	 325	 145	Bucket
	 326	 146	Water bucket
	 327	 147	Lava bucket
	 328	 148	Minecart
	 329	 149	Saddle
	 330	 14A	 Iron door
	 331	 14B	Redstone
	 332	 14C	Snowball
	 333	 14D	Boat
	 334	 14E	Leather
	 335	 14F	Milk
	 336	 150	Clay Brick
	 337	 151	Clay
	 338	 152	Sugar Cane
	 339	 153	Paper
	 340	 154	Book
	 341	 155	Slimeball
	 342	 156	Minecart with Chest
	 343	 157	Minecart with Furnace
	 344	 158	Egg
	 345	 159	Compass
	 346	 15A	Fishing Rod
	 347	 15B	Clock
	 348	 15C	Glowstone Dust
	 349	 15D	Raw Fish
	 350	 15E	Cooked Fish
	 351	 15F	Dye D
	 352	 160	Bone
	 353	 161	Sugar
	 354	 162	Cake
	 355	 163	Bed
	 356	 164	Redstone Repeater
	 357	 165	Cookie
	 358	 166	Map
	 359	 167	Shears
	 360	 168	Melon (Slice)
	 361	 169	Pumpkin Seeds
	 362	 16A	Melon Seeds
	 363	 16B	Raw Beef
	 364	 16C	Steak
	 365	 16D	Raw Chicken
	 366	 16E	Cooked Chicken
	 367	 16F	Rotten Flesh
	 368	 170	Ender Pearl
	 369	 171	Blaze Rod
	 370	 172	Ghast Tear
	 371	 173	Gold Nugget
	 372	 174	Nether Wart
	 373	 175	Potions D
	 374	 176	Glass Bottle
	 375	 177	Spider Eye
	 376	 178	Fermented Spider Eye
	 377	 179	Blaze Powder
	 378	 180	Magma Cream
	 2256	 8D0	13 Disc
	 2257	 8D1	Cat Disc
	 2258	 8D2	blocks Disc
	 2259	 8D3	chirp Disc
	 2260	 8D4	far Disc
EOT

    attr_accessor :packets, :packet_rate, :bot

    def initialize(bot)
      @bot = bot
      @packets = 0
      @packet_rate = 0
    end

    def update
      reset_screen
      puts "Packets: #{packets}\t#{packet_rate} packets per sec"
      print_status
      print_slots
      print_inventory
      print_entity_count
      print_players
      print_chat_messages
    end

    private

    def print_status
      puts("Health:\t#{bot.health}\tFood:\t#{bot.food}\t#{bot.food_saturation}")
      puts("Position:\t#{bot.x}, #{bot.y}, #{bot.z}\t#{bot.stance}")
      puts("Rotation:\t#{bot.yaw} #{bot.pitch}")
      puts("On ground") if bot.on_ground
    end

    def print_slots
      puts "== Slots =="
      bot.windows[0].slots.
        select { |id, slot| (36..44).member?(id) }.
        sort { |a, b| a[0] <=> b[0] }.
        each { |(id, slot)| puts("#{'*' if (id - 36) == bot.holding}Slot #{id - 36}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
    end

    def print_inventory
      puts "== Inventory =="
      bot.windows[0].slots.
        reject { |id, slot| (36..44).member?(id) }.
        sort { |a, b| a[0] <=> b[0] }.
        each { |(id, slot)| puts("Slot #{id}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
    end

    def print_entity_count
      puts "== Entities =="
      puts(entity_count_by_type.collect { |(type, count)| "#{Mobs[type]}\t#{count}" }.join("\n"))
    end

    def entity_count_by_type
      bot.entities.
        collect { |eid, data| data }.
        group_by { |e| e.mob_type }.
        collect { |type, e| [type, e.count ] }
    end

    def print_players
      puts "== Players =="
      puts(named_entities.
           collect { |p| "#{p.name}\t#{p.entity_id}\t#{p.x}, #{p.y}, #{p.z}" }.
           join("\n"))
    end

    def named_entities
      bot.entities.
        inject([]) { |acc, (eid, data)| acc << data if data.kind_of?(MC::Client::NamedEntity); acc }
    end

    def print_chat_messages
      puts "== Chat =="
      bot.chat_messages[0, 5].reverse.each do |msg|
        puts "#{msg}"
      end
    end

    def reset_screen
      print("\033[0;0f\033[2J")
    end
  end
end
