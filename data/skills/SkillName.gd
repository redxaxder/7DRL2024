class_name SkillName

const adjectives = [
	"Aphotic",
	"Draconic",
	"Modest",
	"Inscrutable",
	"Miraculous",
	"Hangman's",
	"Monster's",
	"Serpent's",
	"Devil's",
	"Burly",
	"Poisonous",
	"Mastadon's",
	"Absolute",
]

const trailers = [
	"of the World",
	"against Greed",
	"against Strength",
	"of the Weasel",
	"with Haste",
	"Beyond the Limit",
]

const mains = [
	"Reach",
	"Assailment",
	"Beheading",
	"Strike",
	"Disgrace",
	"Dementia",
	"Slaughter",
	"Luck",
	"Starve",
	"Edge",
	"Tooth",
	"Stone",
	"Tomorrow",
	"Assault",
	"Shout",
	"Glory",
	"Leap"
]

static func generate_name() -> String:
	var name: String = ""
	var num_adjectives = randi() % 2 + 1
	var available_adjectives = DataUtil.deep_dup(adjectives)
	available_adjectives.shuffle()	
	var has_trailer: bool = randf() < 0.2
	for i in num_adjectives:
		name += available_adjectives.pop_front() + " "
	name += mains[randi() % mains.size()]
	if has_trailer:
		name += " " + trailers[randi() % trailers.size()]
	return name

static func name_hint(effect, skill, target) -> NameHint:
	var hint = NameHint.new()
	hint.effect_hint = effect
	hint.skill_kind_hint = skill
	hint.target_hint = target
	return hint
