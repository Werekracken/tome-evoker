long_name = "Evoker"
short_name = "evoker"
for_module = "tome"
version = {1,7,2}
addon_version = {1,2,3}
weight = 2000
author = {"Werekracken"}
tags = {"class", "evoker", "cursed", "corrupted", "demon", "summoner"}
homepage = "https://te4.org/user/102798/addons"
description = [[This adds a new Evoker class which is both corrupted and cursed (though it shows up under Defilers). They are a magic class that does blight and fire damage and evokes both shadows and a demon to serve you.

You can hurt, heal, and have no effect on your demons and shadows differently with different spells. Learning how to work with and around your minions will be key.

NOTE: This addon requires that you have the Ashes DLC active.

https://github.com/Werekracken/tome-evoker

---Generic talents
corruption/black-magic
corruption/torment
cursed/cursed-form
cunning/survival - locked (because everyone gets it)
cursed/diabolical

-Cursed/Diabolical:

Demonic Pulse:
You sacrifice 10%% of your current health to send out a pulse of demonic energy in radius 10.
All minions in the pulse gain 25%% global action speed for %d turns and the pulse will attempt to daze all foes for %d turns.
The chance to daze increases with your Mindpower.
You also use your knowledge of the demonic arts to passively obtain unlife, making it so that you only die when your life reaches -%d.

Demon Portal:
You instantly swap places with your demon. This heals both of you for %d life and you gain 5 hate.
The amount healed will increase with your Mindpower.

Speed Demon:
You sacrifice 10%% of your max health in return for speed and power. 
While sustained you gain %d%% movement speed and increase your Mindpower by %d.
The speed bonus will increase with your Willpower.

Abyssal Shield:
Surround yourself with a defensive aura, increasing armor by %d, and inflicting %0.2f fire and %0.2f blight damage to all attacking foes.
Additionally, your vim will enhance your defences, reducing all damage by %d%% of your current vim (currently %d), but never reducing by more than half of the original damage. This will cost vim equal to 5%% of the damage blocked.
The damage will scale with your Mindpower.

---Class talents
corruption/sanguisuge
corruption/blood
corruption/shadowflame
corruption/fearfire - locked
cursed/shadows
cursed/fears
cursed/one-with-shadows - locked
corruption/demon-summons

-Corruption/Demon Summons:

Summon Demon:
Summon a demon by sacrificing 50%% of your current health. Your demon's primary stat will be improved by %d, its two secondary stats by %d.
At talent level one, you may summon an fiery imp; at level three a shadow clad dúathedlen; and at level six an awful wretch.
Summoned demons can only be maintained up to a range of %d, and will rematerialize next to you if this range is exceeded.
Only one summoned demon may be active at a time, and the stat bonuses will improve with your Spellpower.

Demon Unity:
You now gain %d%% spell speed while Summon Demon: Imp is active, %d%% resist all while Summon Demon: Dúathedlen is active, and %d Mindpower while Summon Demon: Wretch is active. 
These bonuses scale with your Spellpower.

Flame Fury:
You sacrifice 10%% of your current health channel the power of Fearscape that resides in your demons and a wave of fire emanates from you knocking back foes within radius %d and setting them ablaze doing %0.2f fire damage over 3 turns.
The damage will increase with your Spellpower.

Improved Summoning:
Your summoned demons are more powerful and know new talents at talent level %d.
Imp: Body of Fire, Burning Hex, and Smoke Bomb.
Dúathedlen: Shadow Combat, Shadow Grasp, and Shadow Veil.
Wretch: Rush, Ruin, and Blood Splash.
As your Improved Summoning talent increases, so do the chances of your demons being summoned with improved gear (ego chance).


---Changelog
v1.0.0
Initial release 

v1.1.0
Took out Demonic Possession and added Demonic Pulse. Moved Improved Summoning to the 4th talent to be the capstone.
Cut total hate pool down to 25. Added a hate cost to Demonic Pulse and to the Summon Demon sustains.
Reduced max_life from 110 to 90.
Improved class description.

v1.2.0
New cursed/diabolical generic tree that replaces cursed/dark-sustenance.
Moved Demonic Pulse to Diabolical tree and replaced it with Flame Fury.
Made demon kills grant the player 1/4 of the hate for the kill.
Changed Duathedlen skills to take out stealth.
Added more sacrifice health costs to skills.

v1.2.1
Fixed typos.
Reduced sustain hate cost on demons and added a hate gain to Demon Portal to address resource starvation on tough single target fights.
Changed the range on Demon Portal to scale with talent points.
Tweaked the talent icon for Speed Demon.

v1.2.2
Fixed some talent descriptions.

v1.2.3
Gave Imp and Wretch movement talents.
Fixed demon equipment so they don't spawn with antimagic items.
Toned down demon chance to get egos on equipment, made level in Improved Summoning increase the chance.
]]
overload = true
superload = false
hooks = true
data = true
