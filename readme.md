# Evoker

- [Evoker](#evoker)
  - [Generic talents](#generic-talents)
    - [Cursed/Diabolical](#curseddiabolical)
      - [__Demonic Pulse__](#demonic-pulse)
      - [__Demon Portal__](#demon-portal)
      - [__Speed Demon__](#speed-demon)
      - [__Abyssal Shield__](#abyssal-shield)
  - [Class talents](#class-talents)
    - [Corruption/Demon Summons](#corruptiondemon-summons)
      - [__Summon Demon__](#summon-demon)
      - [__Demon Unity__](#demon-unity)
      - [__Flame Fury__](#flame-fury)
      - [__Improved Summoning__](#improved-summoning)
  - [Changelog](#changelog)

---

This addon for [Tales of Maj'Eyal](https://te4.org/) adds a new Evoker class which is both corrupted and cursed (it is available under Defilers). They are a magic class that does blight and fire damage and evokes both shadows and a demon to serve you.
You can hurt, heal, and have no effect on your demons and shadows differently with different spells. Learning how to work with and around your minions will be key.
__NOTE:__ This addon requires that you have the Ashes DLC active.

[Github](https://github.com/Werekracken/tome-evoker)
[Download](https://te4.org/games/addons/tome/evoker)
[Forum](https://forums.te4.org/viewtopic.php?f=50&t=52022)

## Generic talents

cursed/cursed-form
cursed/diabolical
cunning/survival - locked (because everyone gets it)
cursed/cursed-aura - optional

### Cursed/Diabolical

#### __Demonic Pulse__

You sacrifice 10%% of your current health to send out a pulse of demonic energy in radius 10.
All minions in the pulse gain 25%% global action speed for %d turns and the pulse will attempt to daze all foes for %d turns.
You also use your knowledge of the demonic arts to passively obtain unlife, making it so that you only die when your life reaches -%d.
The amount of unlife and the chance to daze increases with your Mindpower.

#### __Demon Portal__

You instantly swap places with your demon. This heals both of you for %d life and you gain 5 hate.
Afterwards, your demon and yourself will be out of phase for 3 turns. In this state all new negative status effects duration is reduced by %d%%, your defense is increased by %d and all your resistances by %d%%.
The amount healed and out of phase bonuses will increase with your Mindpower.

#### __Speed Demon__

You sacrifice 10%% of your max health in return for speed and power.
While sustained you gain %d%% movement speed and increase your Mindpower by %d.
The speed bonus will increase with your Willpower.

#### __Abyssal Shield__

Surround yourself with a defensive aura, increasing armor by %d, and inflicting %0.2f fire and %0.2f blight damage to all attacking foes.
Additionally, your vim will enhance your defences, reducing all damage by %d%% of your current vim (currently %d), but never reducing by more than half of the original damage. This will cost vim equal to 5%% of the damage blocked.
The damage will scale with your Mindpower.

## Class talents

corruption/demon-summons
corruption/sanguisuge
corruption/shadowflame
corruption/vim
cursed/darkness
cursed/fears
corruption/blood - locked
corruption/doom-covenant - locked
corruption/fearfire - locked

### Corruption/Demon Summons

#### __Summon Demon__

Summon a demon by sacrificing 50%% of your current health. Your demon's primary stat will be improved by %d, its two secondary stats by %d.
At talent level one, you may summon an fiery imp; at level three a shadowy dúathedlen; and at level five a grotesque uruivellas.
Summoned demons can only be maintained up to a range of %d, and will rematerialize next to you if this range is exceeded.
Only one summoned demon may be active at a time, and the stat bonuses will improve with your Spellpower.

#### __Demon Unity__

You now gain %d%% spell speed while Summoned Demon: Imp is active, %d%% resist all while Summoned Demon: Dúathedlen is active, and %d Mindpower while Summoned Demon: Uruivellas is active.
(Takes effect upon summoning.)
These bonuses scale with your Spellpower.

#### __Flame Fury__

You sacrifice 10%% of your current health channel the power of Fearscape that resides in your demons and a wave of fire emanates from you knocking back foes within radius %d and setting them ablaze doing %0.2f fire damage over 3 turns.
The damage will increase with your Spellpower.

#### __Improved Summoning__

Your summoned demons are more powerful and know new talents at talent level %d.
Imp: Flame Shock, Firestorm, and Burning Hex.
Dúathedlen: Shadow Combat, Shadow Grasp, and Shadow Veil.
Uruivellas: Rush, Draining Assault, and Blindside.
As your Improved Summoning talent increases, so do the chances of your demons being summoned with improved gear (ego chance).

## Changelog

v1.2.5
This is an overhaul of the class because it didn't feel as good to play and balanced as I wanted it to.

- Increased max hate a little. It's still a small pool, but doesn't feel as punishing.
- Increased the level and stat requirements across the board for the Diabolical and Demon Summons trees. Now new demons and levels in Improved Summoming feel special.
- Took out both shadows trees and Black Magic. Added Darkness, Vim, and Doom Covenant (locked) trees. Locked Fearfire. Took out Torment so that you have to wait to use higher vim cost skill until you have more vim in your pool, or use your life with Bloodcasting.
- Made demon summons immune to fear and tweaked their life, armor, and defense to give them a bit more survivability.
- Changed demon summons to start off tiny and grow as you level which is fun with Nekarcos's Visible Size Categories. Without Nekarcos's addon the dúathedlen and uruivellas will be graphically very large even if their size=tiny.
- Changed the Imp's Improved Summoning skills.
- Toned down Improved Summoning so that demons only get one skill with the 1st point, improve that skill with the 2nd, get a second skill and improve the first skill with the 3rd point, improve them both with the 4th point, and get a third skill and improve the previous two skills with the 5th point.
- Changed the wretch to an uruivellas (minotaur-like demon) and gave it a 2Her to help differentiate it from the dúathedlen (shadow demon).
- Fixed the dúathedlen image.

v1.2.4
Reduced pre-req for Blighted Summoning to apply to demons. Fixed imp sometimes missing equipment. Fixed ego chances for demon equipment. Increased imp defense. Gave dúathedlen a regen talent. Added out-of-phase to Demon Portal. Set demon speed equal to yours. Took out some preset talent points to let you spend them as you want. Made Evoker life rating equal to the highest mage (alchemist). Balanced imp phase door. Some hate balancing.

v1.2.3
Gave Imp and Wretch movement talents.
Fixed demon equipment so they don't spawn with antimagic items.
Toned down demon chance to get egos on equipment, made level in Improved Summoning increase the chance.

v1.2.2
Fixed some talent descriptions.

v1.2.1
Fixed typos.
Reduced sustain hate cost on demons and added a hate gain to Demon Portal to address resource starvation on tough single target fights.
Changed the range on Demon Portal to scale with talent points.
Tweaked the talent icon for Speed Demon.

v1.2.0
New cursed/diabolical generic tree that replaces cursed/dark-sustenance.
Moved Demonic Pulse to Diabolical tree and replaced it with Flame Fury.
Made demon kills grant the player 1/4 of the hate for the kill.
Changed Duathedlen skills to take out stealth.
Added more sacrifice health costs to skills.

v1.1.0
Took out Demonic Possession and added Demonic Pulse. Moved Improved Summoning to the 4th talent to be the capstone.
Cut total hate pool down to 25. Added a hate cost to Demonic Pulse and to the Summon Demon sustains.
Reduced max_life from 110 to 90.
Improved class description.

v1.0.0
Initial release
