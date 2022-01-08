damDesc = Talents.main_env.damDesc

demons_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 4 end },
	level = function(level) return 0 + (level-1) * 6 end,
}
demons_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 4 end },
	level = function(level) return 4 + (level-1) * 6 end,
}
demons_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 4 end },
	level = function(level) return 8 + (level-1) * 6 end,
}
demons_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 4 end },
	level = function(level) return 12 + (level-1) * 6 end,
}

diabolical_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 4 end },
	level = function(level) return 0 + (level-1) * 6 end,
}
diabolical_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 4 end },
	level = function(level) return 4 + (level-1) * 6 end,
}
diabolical_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 4 end },
	level = function(level) return 8 + (level-1) * 6 end,
}
diabolical_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 4 end },
	level = function(level) return 12 + (level-1) * 6 end,
}

corrs_req1 = Talents.main_env.corrs_req1
corrs_req2 = Talents.main_env.corrs_req2
corrs_req3 = Talents.main_env.corrs_req3
corrs_req4 = Talents.main_env.corrs_req4

cursed_wil_req1 = Talents.main_env.cursed_wil_req1
cursed_wil_req2 = Talents.main_env.cursed_wil_req2
cursed_wil_req3 = Talents.main_env.cursed_wil_req3
cursed_wil_req4 = Talents.main_env.cursed_wil_req4

if not Talents.talents_types_def["corruption/demon-summons"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/demon-summons", name = _t"demon summons", description = _t"Summon a demon to do your bidding." }
    load("/data-evoker/talents/corruptions/demon-summons.lua")
end
if not Talents.talents_types_def["cursed/diabolical"] then
    newTalentType{ allow_random=true, no_silence=true, is_mind=true, generic=true, type="cursed/diabolical", name = _t"diabolical", description = _t"You learn to manipulate a bit of the diabolic energy emanating from the Fearscape." }
    load("/data-evoker/talents/cursed/diabolical.lua")
end
