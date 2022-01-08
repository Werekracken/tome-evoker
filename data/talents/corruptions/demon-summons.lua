-- Cancel Demon Summons
local function cancelDemonSummons(self, id)
	local forms = {self.T_WK_SUMMON_DEMON_IMP, self.T_WK_SUMMON_DEMON_DUATHEDLEN, self.T_WK_SUMMON_DEMON_URUIVELLAS}
	for i, t in ipairs(forms) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
		-- Put other demon summons on cooldown
		if id and id ~= t then
			if self:knowTalent(t) then
				self:startTalentCooldown(t)
			end
		end
	end
end

-- Set up our act function so we don't run all over the map
local function setupAct(self)
	self.on_act = function(self) -- luacheck: ignore 432
		local tid = self.summoning_tid
		if not game.level:hasEntity(self.summoner) or self.summoner.dead or not self.summoner:isTalentActive(tid) then
			game:onTickEnd(function()self:die(self)end)
		end
		if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > 10 then
			local x, y = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				return
			end
			-- Clear it's targeting on teleport
			self:setTarget(nil)
			self:move(x, y, true)
			game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
		end
	end
end

-- And our die function to make sure our sustain is disabled properly
local function setupDie(self)
	self.on_die = function(self) -- luacheck: ignore 432
		local tid = self.summoning_tid
		game:onTickEnd(function()
			if self.summoner:isTalentActive(tid) then
				self.summoner:forceUseTalent(tid, {ignore_energy=true})
			end
		end)
		-- Pass our summoner back as the target if we're controlled...  to prevent super cheese.
		if game.player == self then
			local tg = {type="ball", radius=10}
			self:project(tg, self.x, self.y, function(tx, ty)
				local target = game.level.map(tx, ty, engine.Map.ACTOR)
				if target and target.ai_target.actor == self then
					target:setTarget(self.summoner)
				end
			end)
		end
	end
end

-- Build our thought-form
function setupSummonedDemon(self, m, x, y, t)
	-- Set up some basic stuff
	m.display = "p"
	m.blood_color = colors.BLACK
	m.type = "demon"
	m.subtype = "summoned"
	m.demon = 1

	m.summoner_gain_exp=true
	m.faction = self.faction
	m.no_inventory_access = true
	m.rank = 2
	m.infravision = 10
	m.lite = 1
	m.no_breath = 1
	m.move_others = true
	m.fear_immune = 1

	-- Less tedium
	m.life_regen = 1
	m.stamina_regen = 1
	m.mana_regen = 1
	m.vim_regen = 1

	-- Make sure we don't gain anything from leveling
	m.autolevel = "none"
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.exp_worth = 0
	m.no_points_on_levelup = true
	m.silent_levelup = true
	m.level_range = {self.level, self.level}

	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	m.save_hotkeys = true

	-- Add them to the party
	if game.party:hasMember(self) then
		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control="no",
			type="demon",
			title=_t"demon",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end

	-- Build our act and die functions
	m.summoning_tid = t.id
	setupAct(m); setupDie(m)

	-- Add the thought-form to the level
	m:resolve() m:resolve(nil, true)
	m:forceLevelup(self.level)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
	if m.name == "summoned demon imp" then
		m.ai_tactic.safe_range = 2
	end

	self:attr("summoned_times", 99)
end

-- demon-summons
newTalent{
	name = "Summon Demon: Imp",
	short_name = "WK_SUMMON_DEMON_IMP",
	type = {"corruption/other", 1},
	image = "talents/wk_imp.png",
	points = 5,
	require = demons_req1,
	sustain_vim = 40,
	sustain_hate = 10,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 5,
	range = 10,
	no_unlearn_last = true,
	getStatBonus = function(self) local t = self:getTalentFromId(self.T_WK_SUMMON_DEMON) return t.getStatBonus(self, t) end,
	activate = function(self, t)
		cancelDemonSummons(self, t.id)

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		-- Do our stat bonuses here so we only roll for crit once
		local stat_bonus = math.floor(self:spellCrit(t.getStatBonus(self, t)))

		local NPC = require "mod.class.NPC"
		local m = NPC.new{ _no_upvalues_check=true,
			name = _t"summoned demon imp", summoner = self,
			power_source = {arcane=true},
			color=colors.DARK_RED, image = "npc/demon_minor_fire_imp.png",
			shader = "shadow_simulacrum",
			shader_args = { color = {0.4, 0.0, 0.0}, base = 0.7, time_factor = 10000 },
			desc = _t[[A summoned demon imp. It appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, BODY = 1, FINGER = 2},
			movement_speed = self.movement_speed,
			global_speed_base = self.global_speed,
			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=10 },
			ai_tactic = resolvers.tactic("melee"),
			size_category = math.floor(self.level/10),
			max_life = resolvers.rngavg(70,80),
			life_rating = 10,
			combat_armor = 0, combat_def = math.floor(self.level/5),
			inc_stats = {
				cun = stat_bonus / 2,
				mag = stat_bonus,
				wil = stat_bonus / 2,
			},
			resists = {[DamageType.FIRE] = 100},
			summoner_hate_per_kill = self.hate_per_kill/2,
			resolvers.talents{
				[Talents.T_LIGHT_ARMOUR_TRAINING]= math.ceil(self.level/10),
				[Talents.T_STAFF_MASTERY]= math.ceil(self.level/10),
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10), -- Combat Accuracy

				[Talents.T_FLAME]= math.ceil(self.level/10),

				[Talents.T_FLAMESHOCK]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING)),
				[Talents.T_FIRE_STORM]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 2),
				[Talents.T_BURNING_HEX]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 4),
			},
			resolvers.inscription("RUNE:_CONTROLLED_PHASE_DOOR", {cooldown=10, range=5, dur=5, power=15}),
			resolvers.equip{
				{type="weapon", subtype="staff", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="armor", subtype="cloth", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="jewelry", subtype="ring", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="jewelry", subtype="ring", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupSummonedDemon(self, m, x, y, t)
		game:playSoundNear(self, "talents/spell_generic")

		self.life = self.life * 0.5 --50% life cost

		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_WK_DEMON_UNITY) then
			local tal = self:getTalentFromId(self.T_WK_DEMON_UNITY)
			ret.speed = self:addTemporaryValue("combat_spellspeed", tal.getSpeedPower(self, t)/100)
		end
		return ret
	end,
	deactivate = function(self, t, p) -- luacheck: ignore 212
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.speed then self:removeTemporaryValue("combat_spellspeed", p.speed) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self)
		return ([[Summons a fire casting imp by sacrificing 50%% of your current health. The imp knows Flame and Controlled Phase Door, and has +%d Magic, +%d Cunning, and +%d Willpower.
		Activating this talent will put all other demon summons on cooldown.
		The stat bonuses will improve with your Spellpower.]]):tformat(stat, stat/2, stat/2)
	end,
}

newTalent{
	name = "Summon Demon: Dúathedlen",
	short_name = "WK_SUMMON_DEMON_DUATHEDLEN",
	type = {"corruption/other", 1},
	image = "talents/wk_duathedlen.png",
	points = 5,
	require = demons_req1,
	sustain_vim = 40,
	sustain_hate = 10,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 5,
	range = 10,
	no_unlearn_last = true,
	getStatBonus = function(self) local t = self:getTalentFromId(self.T_WK_SUMMON_DEMON) return t.getStatBonus(self, t) end,
	activate = function(self, t)
		cancelDemonSummons(self, t.id)

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		-- Do our stat bonuses here so we only roll for crit once
		local stat_bonus = math.floor(self:spellCrit(t.getStatBonus(self, t)))

		local NPC = require "mod.class.NPC"
		local m = NPC.new{ _no_upvalues_check=true,
			name = _t"summoned demon dúathedlen", summoner = self,
			power_source = {arcane=true},
			--color=colors.DARK_GREY, image="invis.png", add_mos = {{image="npc/demon_major_duathedlen.png", display_h=2, display_y=-1}},
			color=colors.DARK_GREY, image="invis.png", add_mos = {{image="npc/demon_major_duathedlen.png", display_h=1, display_y=-1}},
			shader = "shadow_simulacrum",
			shader_args = { color = {0.1, 0.1, 0.1}, base = 0.9, time_factor = 10000 },
			desc = _t[[A summoned shadow demon shrouded in shadows. It wields daggers and appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, BODY = 1},
			movement_speed = self.movement_speed,
			global_speed_base = self.global_speed,
			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_complex", talent_in=3, ally_compassion=10 },
			ai_tactic = resolvers.tactic("melee"),
			size_category = math.floor(self.level/10),
			max_life = resolvers.rngavg(100,120),
			life_rating = 13,
			combat_armor = 0, combat_def = 0,
			inc_stats = {
				mag = stat_bonus / 2,
				cun = stat_bonus / 2,
				dex = stat_bonus,
			},

			resists = {[DamageType.DARKNESS] = 100},
			summoner_hate_per_kill = self.hate_per_kill/2,

			resolvers.talents{
				[Talents.T_LIGHT_ARMOUR_TRAINING]= math.ceil(self.level/10),
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10), -- Combat Accuracy
				[Talents.T_KNIFE_MASTERY] = math.ceil(self.level/10),
				[Talents.T_DARK_VISION] = math.ceil(self.level/10),

				[Talents.T_SHADOWSTEP]= math.ceil(self.level/10),
				[Talents.T_COUNTER_ATTACK]= math.ceil(self.level/10),


				[Talents.T_SHADOW_COMBAT]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING)),
				[Talents.T_SHADOW_GRASP]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 2),
				[Talents.T_SHADOW_VEIL]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 4),
			},
			resolvers.equip{
				{type="weapon", subtype="dagger", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="weapon", subtype="dagger", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="armor", subtype="light", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupSummonedDemon(self, m, x, y, t)
		game:playSoundNear(self, "talents/spell_generic")

		self.life = self.life * 0.5 --50% life cost

		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_WK_DEMON_UNITY) then
			local tal = self:getTalentFromId(self.T_WK_DEMON_UNITY)
			ret.resist = self:addTemporaryValue("resists", {all= tal.getDefensePower(self, t)})
		end
		return ret
	end,
	deactivate = function(self, t, p) -- luacheck: ignore 212
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.resist then self:removeTemporaryValue("resists", p.resist) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self)
		return ([[Summons a shadow demon by sacrificing 50%% of your current health. The dúathedlen can see through shadows, knows Shadowstep and Regeneration, and has +%d Dexterity, +%d Cunning, and +%d Magic.
		Activating this talent will put all other demon summons on cooldown.
		The stat bonuses will improve with your Spellpower.]]):tformat(stat, stat/2, stat/2)
	end,
}

newTalent{
	name = "Summon Demon: Uruivellas",
	short_name = "WK_SUMMON_DEMON_URUIVELLAS",
	type = {"corruption/other", 1},
	image = "talents/wk_uruivellas.png",
	points = 5,
	require = demons_req1,
	sustain_vim = 40,
	sustain_hate = 10,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 5,
	range = 10,
	no_unlearn_last = true,
	getStatBonus = function(self) local t = self:getTalentFromId(self.T_WK_SUMMON_DEMON) return t.getStatBonus(self, t) end,
	activate = function(self, t)
		cancelDemonSummons(self, t.id)

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		-- Do our stat bonuses here so we only roll for crit once
		local stat_bonus = math.floor(self:spellCrit(t.getStatBonus(self, t)))

		local NPC = require "mod.class.NPC"
		local m = NPC.new{ _no_upvalues_check=true,
			name = _t"summoned demon uruivellas", summoner = self,
			power_source = {arcane=true},
			color=colors.DARK_GREEN, image="invis.png", add_mos = {{image="npc/demon_major_uruivellas.png", display_h=2, display_y=-1}},
			shader = "shadow_simulacrum",
			shader_args = { color = {0.3, 0.3, 0.0}, base = 0.3, time_factor = 10000 },
			desc = _t[[A summoned minotaur-like demon wielding a large rusty axe in both hands and clad in soiled heavy armor. It appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, HANDS = 1, BODY = 1},
			movement_speed = self.movement_speed,
			global_speed_base = self.global_speed,
			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_complex", talent_in=3, ally_compassion=10 },
			ai_tactic = resolvers.tactic("melee"),
			size_category = math.floor(self.level/10),
			max_life = resolvers.rngavg(150,170),
			life_rating = 16,
			combat_armor = math.floor(self.level/5), combat_def = 0,
			inc_stats = {
				str = stat_bonus,
				mag = stat_bonus / 2,
				con = stat_bonus / 2,
			},

			resists = {[DamageType.BLIGHT] = 100},
			summoner_hate_per_kill = self.hate_per_kill/2,

			resolvers.talents{
				[Talents.T_ARMOUR_TRAINING]= 1 + math.ceil(self.level/10),
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10), -- Combat Accuracy
				[Talents.T_WEAPONS_MASTERY]= math.ceil(self.level/10),

				[Talents.T_RUIN]= math.ceil(self.level/10),
				[Talents.T_ACID_BLOOD]= math.ceil(self.level/10),

				[Talents.T_RUSH]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING)),
				[Talents.T_DRAINING_ASSAULT]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 2),
				[Talents.T_BLINDSIDE]= math.floor(self:getTalentLevel(self.T_WK_IMPROVED_SUMMONING) - 4),

			},
			resolvers.equip{
				{type="weapon", subtype="battleaxe", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="armor", subtype="heavy", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
				{type="armor", subtype="hands", autoreq=true, forbid_power_source={antimagic=true}, ego_chance = math.ceil(-100+(40*self:getTalentLevelRaw(self.T_WK_IMPROVED_SUMMONING))), not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupSummonedDemon(self, m, x, y, t)
		game:playSoundNear(self, "talents/spell_generic")

		self.life = self.life * 0.5 --50% life cost

		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_WK_DEMON_UNITY) then
			local tal = self:getTalentFromId(self.T_WK_DEMON_UNITY)
			ret.power = self:addTemporaryValue("combat_mindpower", tal.getOffensePower(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p) -- luacheck: ignore 212
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.power then self:removeTemporaryValue("combat_mindpower", p.power) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self)
		return ([[Summons a strong minotaur-like demon by sacrificing 50%% of your current health. The uruivellas has Acid Blood, knows Ruin, and has +%d Strength, +%d Dexterity, and +%d Constitution.
		Activating this talent will put all other demon summons on cooldown.
		The stat bonuses will improve with your Spellpower.]]):tformat(stat, stat/2, stat/2)
	end,
}

newTalent{
	name = "Summon Demon",
	short_name = "WK_SUMMON_DEMON",
	type = {"corruption/demon-summons", 1},
	image = "talents/wk_summon_demon.png",
	points = 5,
	require = demons_req1,
	mode = "passive",
	range = 10,
	unlearn_on_clone = true,
	getStatBonus = function(self, t) return self:combatTalentSpellDamage(t, 5, 100) end,
	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 1 and not self:knowTalent(self.T_WK_SUMMON_DEMON_IMP) then
			self:learnTalent(self.T_WK_SUMMON_DEMON_IMP, true)
		end
		if self:getTalentLevel(t) >= 3 and not self:knowTalent(self.T_WK_SUMMON_DEMON_DUATHEDLEN) then
			self:learnTalent(self.T_WK_SUMMON_DEMON_DUATHEDLEN, true)
		end
		if self:getTalentLevel(t) >= 6 and not self:knowTalent(self.T_WK_SUMMON_DEMON_URUIVELLAS) then
			self:learnTalent(self.T_WK_SUMMON_DEMON_URUIVELLAS, true)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 1 and self:knowTalent(self.T_WK_SUMMON_DEMON_IMP) then
			self:unlearnTalent(self.T_WK_SUMMON_DEMON_IMP)
		end
		if self:getTalentLevel(t) < 3 and self:knowTalent(self.T_WK_SUMMON_DEMON_DUATHEDLEN) then
			self:unlearnTalent(self.T_WK_SUMMON_DEMON_DUATHEDLEN)
		end
		if self:getTalentLevel(t) < 6 and self:knowTalent(self.T_WK_SUMMON_DEMON_URUIVELLAS) then
			self:unlearnTalent(self.T_WK_SUMMON_DEMON_URUIVELLAS)
		end
	end,
	info = function(self, t)
		local bonus = t.getStatBonus(self, t)
		local range = self:getTalentRange(t)
		return([[Summon a demon by sacrificing 50%% of your current health. Your demon's primary stat will be improved by %d, its two secondary stats by %d.
		At talent level one, you may summon a fiery imp; at level three a shadowy dúathedlen; and at level five a grotesque uruivellas.
		Summoned demons can only be maintained up to a range of %d, and will rematerialize next to you if this range is exceeded.
		Only one summoned demon may be active at a time, and the stat bonuses will improve with your Spellpower.]]):tformat(bonus, bonus/2, range)
	end,
}

newTalent{
	name = "Demon Unity", short_name = "WK_DEMON_UNITY",
	type = {"corruption/demon-summons", 2},
	image = "talents/wk_unity.png",
	points = 5,
	require = demons_req2,
	mode = "passive",
	getSpeedPower = function(self, t) return self:combatTalentSpellDamage(t, 5, 15) end,
	getDefensePower = function(self, t) return self:combatTalentSpellDamage(t, 1, 10) end,
	getOffensePower = function(self, t) return self:combatTalentSpellDamage(t, 10, 30) end,
	info = function(self, t)
		local speed = t.getSpeedPower(self, t)
		local defense = t.getDefensePower(self, t)
		local offense = t.getOffensePower(self, t)
		return([[You now gain %d%% spell speed while Summoned Demon: Imp is active, %d%% resist all while Summoned Demon: Dúathedlen is active, and %d Mindpower while Summoned Demon: Uruivellas is active.
		(Takes effect upon summoning.)
		These bonuses scale with your Spellpower.]]):tformat(speed, defense, offense)
	end,
}

newTalent{
	name = "Flame Fury", short_name = "WK_FLAME_FURY",
    image = "talents/wk_flame_fury.png",
	type = {"corruption/demon-summons", 3},
	points = 5,
	require = demons_req3,
	vim = 10,
	hate = 5,
	cooldown = 10,
	tactical = { ATTACKAREA = 2, DISABLE = 2, ESCAPE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK_MIND, {dist=3, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fire")

		self.life = self.life * 0.9 --10% life cost
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You sacrifice 10%% of your current health to channel the power of Fearscape that resides in your demons and a wave of fire emanates from you knocking back foes within radius %d and setting them ablaze doing %0.2f fire damage over 3 turns.
		The damage will increase with your Spellpower.]]):tformat(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Improved Summoning",
	short_name = "WK_IMPROVED_SUMMONING",
	type = {"corruption/demon-summons", 4},
	image = "talents/wk_major_summoning.png",
	points = 5,
	require = demons_req4,
	mode = "passive",
	info = function(self, t)
		local level = math.floor(self:getTalentLevel(t))
		return([[As you improve your skill at summoning your summoned demons learn new talents and use them at an increased level.
		Imp: Flame Shock, Firestorm, and Burning Hex.
		Dúathedlen: Shadow Combat, Shadow Grasp, and Shadow Veil.
		Uruivellas: Rush, Draining Assault, and Blindside.
		Also as your Improved Summoning talent increases, so do the chances of your demons being summoned with improved gear (ego chance).]]):tformat(level)
	end,
}
