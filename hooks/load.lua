local class = require "engine.class"
local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"

class:bindHook("ToME:load", function(self, data) -- luacheck: ignore 212
	ActorTalents:loadDefinition("/data-evoker/talents/talents.lua")
	Birther:loadDefinition("/data-evoker/birth/classes/corrupted.lua")
end)

