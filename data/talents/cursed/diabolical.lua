newTalent{
	name = "Demonic Pulse", short_name = "WK_DEMONIC_PULSE",
	type = {"cursed/diabolical", 1},
	image = "talents/wk_over_mind.png",
	points = 5,
	require = cursed_wil_req1,
	vim = 10,
	hate = 5,
	cooldown = 18,
	tactical = { BUFF=2, DISABLE = {daze=2} },
	range = 0,
	radius = 10,
	target = function(self, t) return {type="ball", range=0, radius=self:getTalentRadius(t), ignore_nullify_all_friendlyfire=true} end,
	requires_target = true,
	getSpeed = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
	getDaze = function(self, t) return math.floor(self:combatTalentScale(t, 4, 10)) end,
	getDieAt = function(self, t) return self:combatTalentMindDamage(t, 10, 200) end,
	action = function(self, t, p)
		local tg = self:getTalentTarget(t)
		self:projectApply(tg, self.x, self.y, Map.ACTOR, function(target)
			if self:reactionToward(target) < 0 then
				if target:canBe("stun") then target:setEffect(target.EFF_DAZED, t:_getDaze(self), {apply_power=self:combatMindpower()}) end
			elseif target.summoner == self and target.demon or target.is_doomed_shadow then
				target:setEffect(target.EFF_HASTE, t:_getSpeed(self), {power=0.25})
			end
		end)

		self.life = self.life * 0.9 --10% life cost

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_darkness", {radius=tg.radius})
		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "die_at", -t.getDieAt(self, t))
	end,
	info = function(self, t)
		return ([[You sacrifice 10%% of your current health to send out a pulse of demonic energy in radius 10.
		All minions in the pulse gain 25%% global action speed for %d turns and the pulse will attempt to daze all foes for %d turns.
		You also use your knowledge of the demonic arts to passively obtain unlife, making it so that you only die when your life reaches -%d.
		The amount of unlife and the chance to daze increases with your Mindpower.]]):
		tformat(t:_getSpeed(self), t:_getDaze(self), t.getDieAt(self, t))
	end,
}

newTalent{
	name = "Demon Portal", short_name = "WK_DEMON_PORTAL",
	type = {"cursed/diabolical", 2},
	image = "talents/wk_demon_portal.png",
	points = 5, 
	require = cursed_wil_req2,
	vim = 15,
	--hate = 5,
	range = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 5, 10))) end,
	cooldown = 10,
	tactical = { HEAL = 2, ESCAPE = 3 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true, can_autoaccept=true } end,
	getHeal = function(self, t) return self:combatTalentMindDamage(t, 40, 200) end,
	is_heal = true,
	action = function(self, t)
		-- Find our demon
		local demon = game.party:findMember{type="demon"}
		if not demon then
			game.logPlayer(self, "You need a summoned demon to swap places with.")
			return
		end

		-- Swap places
		local px, py = self.x, self.y
		local gx, gy = demon.x, demon.y

		self:move(gx, gy, true)
		demon:move(px, py, true)
		self:move(gx, gy, true)
		demon:move(px, py, true)
		game.level.map:particleEmitter(px, py, 1, "teleport")
		game.level.map:particleEmitter(gx, gy, 1, "teleport")

		-- Heal self
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		-- Heal demon
		demon:attr("allow_on_heal", 1)
		demon:heal(self:spellCrit(t.getHeal(self, t)), self)
		demon:attr("allow_on_heal", -1)
		-- Gain hate
		self.hate = self.hate + 5

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return([[You instantly swap places with your demon. This heals both of you for %d life and you gain 5 hate.
		The amount healed will increase with your Mindpower.]]):tformat(heal)
	end,
}

newTalent{
	name = "Speed Demon", short_name = "WK_SPEED_DEMON",
	type = {"cursed/diabolical", 3},
	image = "talents/wk_speed_demon.png",
	points = 5, 
	require = cursed_wil_req3,
	mode = "sustained",
	sustain_vim = 10,
	cooldown = 10,
	no_energy=true,
	tactical = { SELF = { ESCAPE = 1 }, CLOSEIN = 1},
	getSpeed = function(self, t) return self:combatTalentStatDamage(t, "wil", 0.1, 1.1) end,
	getPower = function(self, t) return self:getTalentLevel(t) end,
	activate = function(self, t)
		self.max_life = self.max_life * 0.9 --10% life cost
		return {
			speed = self:addTemporaryValue("movement_speed", t.getSpeed(self, t)),
			power = self:addTemporaryValue("combat_mindpower", t.getPower(self, t))
		}
	end,
	deactivate = function(self, t, p)
		self.max_life = self.max_life * 1.1 --10% life cost
		self:removeTemporaryValue("movement_speed", p.speed)
		self:removeTemporaryValue("combat_mindpower", p.power)
		return true
	end,
	info = function(self, t)
		return([[You sacrifice 10%% of your max life in return for speed and power. 
		While sustained you gain %d%% movement speed and increase your Mindpower by %d.
		The speed bonus will increase with your Willpower.]]):tformat(t.getSpeed(self, t)*100, t.getPower(self, t)*5)
	end,
}

newTalent{
	name = "Abyssal Shield", short_name = "WK_ABYSSAL_SHIELD",
	type = {"cursed/diabolical", 4},
	image = "talents/abyssal_shield.png",
	require = cursed_wil_req4,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_vim = 15,
	no_energy=true,
	no_npc_use = true,
	tactical = { BUFF = 2 },
	statBonus = function(self, t) return self:combatTalentScale(t, 3, 15, 0.75) end,
	defBonus = function(self, t) return self:combatTalentScale(t, 4, 25, 0.8) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_armor", t.statBonus(self, t))
		self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.FIRE]= t.getDamage(self,t), [DamageType.BLIGHT]= t.getDamage(self,t)})
		self:talentTemporaryValue(ret, "demonblood_def", t.defBonus(self, t) / 100)
		ret.particle = self:addParticles(Particles.new("circle", 1, {oversize=1, a=140, shader=true, base_rot=180, appear=12, speed=0, img="abyssal_shield", radius=0}))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a defensive aura, increasing armor by %d, and inflicting %0.2f fire and %0.2f blight damage to all attacking foes.
		Additionally, your vim will enhance your defences, reducing all damage by %d%% of your current vim (currently %d), but never reducing by more than half of the original damage. This will cost vim equal to 5%% of the damage blocked.
		The damage will scale with your Mindpower.]]):
		tformat(
			t.statBonus(self, t),
			damDesc(self, DamageType.FIRE, t.getDamage(self,t)),
			damDesc(self, DamageType.BLIGHT, t.getDamage(self,t)),
			t.defBonus(self, t),
			(t.defBonus(self, t)/100)*self:getVim()
		)
	end,
}