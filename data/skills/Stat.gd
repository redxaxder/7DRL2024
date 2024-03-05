class_name Stat
enum Kind{	Brawn, Brains, Guts, Eyesight, Footwork, Hustle, 
			Accuracy, Crit, Evasion, Damage, Speed, Health,
			Physical, Fire, Ice, Poison,
			PhysicalResist, FireResist, IceResist, PoisonResist,
			MAX}
const NAME = [	"Brawn", "Brains", "Guts", "Eyesight", "Footwork", "Hustle",
				"Accuracy", "Crit", "Evasion", "Power", "Speed", "Health",
				"Physical", "Fire", "Ice", "Poison",
				"Physical Resist", "Fire Resist", "Ice Resist", "Poison Resist"
	]
	
const MINIMUM = [	1, 1, 1, 1, 1, 1, # 6 primary (base) stats don't go below 1 [maybe they could?]
				1, 1, 1, 1, 1, 1, # 6 don't go below 1
				-100,-100,-100,-100, # elemental attack stats can goto -100, where you no longer deal any damage with the element
				-100,-100,-100,-100, # elemental defense at -100 means you take double damage from the element
				]
