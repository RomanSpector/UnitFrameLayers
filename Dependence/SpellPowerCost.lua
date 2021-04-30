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
    [GetSpellInfo(10955)] =
    {
        {type=0, name="MANA", cost=347, minCost=347, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(32375)] =
    {
        {type=0, name="MANA", cost=1274, minCost=1274, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(8129)] = {
        {type=0, name="MANA", cost=540, minCost=540, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(64843)] =
    {
        {type=0, name="MANA", cost=2433, minCost=2433, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48071)] =
    {
        {type=0, name="MANA", cost=695, minCost=695, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(6064)] =
    {
        {type=0, name="MANA", cost=1236, minCost=1236, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48123)] =
    {
        {type=0, name="MANA", cost=579, minCost=579, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48063)] =
    {
        {type=0, name="MANA", cost=1236, minCost=1236, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48171)] =
    {
        {type=0, name="MANA", cost=2317, minCost=2317, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(2053)] =
    {
        {type=0, name="MANA", cost=1043, minCost=1043, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(64901)] =
    {
        {type=0, name="MANA", cost=-UnitPowerMax("player")*1.2, minCost=-UnitPowerMax("player")*1.2, costPercent=-3, costPerSec=-UnitPowerMax("player")*0.3/1.9, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48072)] =
    {
        {type=0, name="MANA", cost=1854, minCost=1854, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48120)] =
    {
        {type=0, name="MANA", cost=1043, minCost=1043, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48135)] =
    {
        {type=0, name="MANA", cost=424, minCost=424, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(53023)] =
    {
        {type=0, name="MANA", cost=853, minCost=853, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(48127)] =
    {
        {type=0, name="MANA", cost=518, minCost=518, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(605)] =
    {
        {type=0, name="MANA", cost=365, minCost=365, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
    [GetSpellInfo(34914)] =
    {
        {type=0, name="MANA", cost=580, minCost=580, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
    },
};

function GetSpellPowerCost(spellName)
    return SpellPowerCostTable[spellName] or {};
end