--[[
    hasRequiredAura
        Boolean - returns false for every spell in the game.
    type 
        /dump UnitPowerType(unit)
        0 = Mana
        1 = Rage
        2 = Focus (hunter pets)
        3 = Energy
        4 = Happiness
        5 = Runes
        6 = Runic Power
    name 
        String - the powerToken of the spell's cost, one of "MANA", "RAGE", "FOCUS", "ENERGY", "HAPPINESS", "RUNES", "RUNIC_POWER", "SOUL_SHARDS", "HOLY_POWER", "STAGGER", "CHI", "FURY", "PAIN", "LUNAR_POWER", "INSANITY".
    cost
        Number - the maximum cost.
    minCost
        Number - the minimum cost.
    requiredAuraID
        Number - returns zero for the vast majority of spells. Read bellow for more detailed information.
    costPercent
        Number - percentual cost.
    costPerSec
        Number - the cost per second for channeled spells.
]]

local SpellPowerCostTable = {
    -- PRIEST
    [48071] = {type=0, name="MANA", cost=695, minCost=695, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0},
};

function GetSpellPowerCost(spellID)
    return SpellPowerCostTable[spellID] or {};
end