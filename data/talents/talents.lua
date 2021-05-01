damDesc = Talents.main_env.damDesc

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
    newTalentType{ allow_random=true, no_silence=true, is_mind=true, generic=true, type="cursed/diabolical", name = _t"diabolical", description = _t"You learn to manipulate a bit of the diabolical emanating from the Fearscape." }
    load("/data-evoker/talents/cursed/diabolical.lua")
end
