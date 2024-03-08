class_name Stat
enum Kind{	Brawn, Brains, Guts, Eyesight, Footwork, Hustle, 
			Accuracy, Crit, Evasion, Damage, Speed, Health,
			Physical, Fire, Ice, Poison,
			PhysicalResist, FireResist, IceResist, PoisonResist,
			MAX}
const NAME = [	"Brawn", "Brains", "Guts", "Eyesight", "Footwork", "Hustle",
				"Accuracy", "Crit", "Evasion", "Power", "Speed", "Health",
				"Physical Power", "Fire Power", "Ice Power", "Poison Power",
				"Physical Resist", "Fire Resist", "Ice Resist", "Poison Resist"
	]
	
const MINIMUM = [	1, 1, 1, 1, 1, 1, # 6 primary (base) stats don't go below 1 [maybe they could?]
				1, 1, 1, 1, 1, 1, # 6 don't go below 1
				0, 0, 0, 0, # elemental attack stats don't go below 0. they are bonuses only, not penalties
				-999,-999,-999,-999, # elemental resists can get low but not crazy low
				]

const DERIVED_STATS = [ Kind.Accuracy, Kind.Crit, Kind.Evasion, Kind.Damage, Kind.Speed, Kind.Health ]
