newBirthDescriptor{
	type = "subclass",
	name = "Evoker",
	desc = {
		_t"Evokers are both corrupted and cursed.",
		_t"They are a magic class that does blight and darkness damage and evokes a demon minion.",
		_t"Their most important stats are Magic and Willpower.",
		_t"It is possible for you and your demons to help or hurt each other with some spells and skills. Learning how to work with and around your minions will be key.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +3 Constitution",
		_t"#LIGHT_BLUE# * +3 Magic, +3 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {arcane=true},
	stats = { mag=3, wil=3, con=3 },
	talents_types = {
		--generic
		["cursed/cursed-form"]={true, 0.3},
		["cursed/diabolical"]={true, 0.3},
		["cunning/survival"]={false, 0},

		--class
		["corruption/demon-summons"]={true, 0.3},
		["corruption/sanguisuge"]={true, 0.3},
		["corruption/shadowflame"]={true, 0.3},
		["corruption/vim"]={true, 0.3},
		["cursed/darkness"]={true, 0.3},
		["cursed/fears"]={true, 0.3},
		["corruption/blood"]={false, 0.3},
		["corruption/doom-covenant"]={false, 0.3},
		["corruption/fearfire"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_WK_DEMONIC_PULSE] = 1,
		[ActorTalents.T_WK_SUMMON_DEMON] = 1,
	},
	copy = {
		class_start_check = start_zone,
		max_life = 90,
		max_hate = 30,
		resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", subtype="staff"},
			OFFHAND = {special=function(e, filter) -- only allow if there is a 1H weapon in MAINHAND
				local who = filter._equipping_entity
				if who then
					local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
					if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
				end
				return false
			end}
		},
		resolvers.equipbirth{ id=true,
		 {type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
		 {type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
		chooseCursedAuraTree = true,
	},
	copy_add = {
		life_rating = -1,
		unused_talents = 2,
		unused_generics = 1,
	},
}

getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Evoker"] = "allow"