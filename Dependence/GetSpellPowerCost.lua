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

local BaseMana = {
    ["DRUID"] = {
        50, 50, 50, 50, 50, 50, 50, 120, 134, 149, 165, 182, 200, 219, 239, 260, 282, 305, 329, 354,
        380, 392, 420, 449, 479, 509, 524, 554, 614, 629, 659, 689, 704, 734, 749, 779, 809, 824, 854,
        854, 869, 899, 914, 944, 959, 989, 1004, 1019, 1049, 1064, 1079, 1109, 1124, 1139, 1154, 1169, 1199, 1214, 1229, 1244,
        1359, 1469, 1582, 1694, 1807, 1919, 2032, 2145, 2257, 2370, 2482, 2595, 2708, 2820, 2933, 3045, 3158, 3270, 3383, 3496
    },
    ["HUNTER"] = {
        65, 65, 65, 98, 98, 98, 98, 166, 166, 166, 166, 166, 166, 298, 298, 298, 298, 298, 298, 298,
        298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 1075, 1075,
        1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075, 1075,
        1075, 2053, 2053, 2053, 2053, 2053, 2053, 2053, 2053, 3383, 3383, 3716, 3716, 3716, 3716, 3716, 3716, 3716, 3716, 5046
    },
    ["MAGE"] = {
        100, 110, 110, 110, 121, 121, 121, 121, 121, 196, 215, 215, 215, 263, 271, 295, 305, 331, 343, 371,
        385, 415, 431, 431, 431, 515, 515, 556, 592, 613, 634, 634, 634, 712, 733, 733, 733, 811, 811, 853,
        853, 853, 916, 916, 916, 916, 916, 1021, 1021, 1021, 1021, 1090, 1090, 1117, 1138, 1138, 1138, 1138, 1138, 1213,
        1213, 1213, 1521, 1521, 1521, 1521, 1932, 2035, 2035, 2241, 2343, 2625, 2625, 2625, 2625, 2625, 2625, 3063, 3063, 3268
    },
    ["PALADIN"] = {
        60, 64, 84, 90, 112, 120, 129, 154, 165, 192, 205, 219, 249, 265, 282, 315, 334, 354, 390, 412,
        435, 459, 499, 525, 552, 579, 621, 648, 675, 579, 621, 648, 675, 702, 729, 756, 798, 825, 852, 879, 906, 933, 960, 987,
        1014, 1041, 1068, 1110, 1137, 1164, 1176, 1203, 1230, 1257, 1284, 1311, 1338, 1365, 1392, 1419, 1446, 1458, 1485, 1512,
        1656, 1800, 1944, 2088, 2232, 2377, 2521, 2665, 2809, 2953, 3097, 3241, 3385, 3529, 3673, 3817, 3962, 4106, 4250, 4394
    },
    ["PRIEST"] = {
        110, 119, 119, 119, 119, 119, 164, 164, 164, 164, 164, 164, 164, 164, 164, 164, 164, 164, 164, 164,
        164, 164, 164, 480, 480, 530, 530, 530, 530, 530, 530, 530, 530, 530, 530, 530, 530, 530, 530, 911,
        911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911, 911,
        911, 911, 911, 911, 911, 911, 911, 911, 911, 2620, 2620, 2868, 2868, 2868, 3242, 3242, 3242, 3242, 3242, 3863
    },
    ["SHAMAN"] = {
        55, 55, 55, 55, 55, 55, 121, 121, 121, 175, 190, 206, 223, 241, 260, 280, 301, 323, 346, 370,
        395, 421, 448, 476, 505, 535, 566, 598, 631, 665, 699, 733, 767, 786, 820, 854, 888, 922, 941, 975,
        1009, 1028, 1062, 1096, 1115, 1149, 1183, 1202, 1236, 1255, 1289, 1313, 1342, 1376, 1395, 1414, 1448, 1467, 1501, 1520,
        1664, 1808, 1951, 2095, 2239, 2383, 2572, 2670, 2814, 2958, 3102, 3246, 3389, 3533, 3677, 3821, 3965, 4108, 4252, 4396
    },
    ["WARLOCK"] = {
        90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90,
        90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90,
        90, 965, 965, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1022, 1522,
        1522, 1522, 1522, 1522, 1522, 1522, 1522, 1522, 1522, 2871, 2871, 2871, 2871, 2871, 2871, 2871, 2871, 2871, 2871, 3856
    },
}

function UnitBaseMana(unit)
    local _, class = UnitClass(unit);
    local level = UnitLevel(unit);
    if ( not BaseMana[class] or level > 80 ) then
        return;
    end

    return BaseMana[class][level];
end

local DATACLASS = {
    ["DRUID"] = {
        [GetSpellInfo(48461)] =
        {
            {type=0, name="MANA", cost=0.11, minCost=0.11, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48463)] =
        {
            {type=0, name="MANA", cost=0.21, minCost=0.21, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(53308)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(33786)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48467)] =
        {
            {type=0, name="MANA", cost=0.81, minCost=0.81, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(18658)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48465)] =
        {
            {type=0, name="MANA", cost=0.16, minCost=0.16, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(26995)] =
        {
            {type=0, name="MANA", cost=0.06, minCost=0.06, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48443)] =
        {
            {type=0, name="MANA", cost=0.29, minCost=0.29, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(50464)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48447)] =
        {
            {type=0, name="MANA", cost=0.7, minCost=0.7, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(50763)] =
        {
            {type=0, name="MANA", cost=0.72, minCost=0.72, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["HUNTER"] = {
        [GetSpellInfo(49052)] =
        {
            {type=0, name="MANA", cost=0.05, minCost=0.05, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(1002)] =
        {
            {type=0, name="MANA", cost=0.01, minCost=0.01, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(14327)] =
        {
            {type=0, name="MANA", cost=0.02, minCost=0.02, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(1515)] =
        {
            {type=0, name="MANA", cost=0.48, minCost=0.48, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["MAGE"] = {
        [GetSpellInfo(42842)] =
        {
            {type=0, name="MANA", cost=0.11, minCost=0.11, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47610)] =
        {
            {type=0, name="MANA", cost=0.14, minCost=0.14, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(42926)] =
        {
            {type=0, name="MANA", cost=0.3, minCost=0.3, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(42859)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(58659)] =
        {
            {type=0, name="MANA", cost=0.8, minCost=0.8, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(11420)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(53142)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49361)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(32267)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(11417)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(11418)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(35717)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(12826)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(27090)] =
        {
            {type=0, name="MANA", cost=0.4, minCost=0.4, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(33717)] =
        {
            {type=0, name="MANA", cost=0.4, minCost=0.4, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(42985)] =
        {
            {type=0, name="MANA", cost=0.75, minCost=0.75, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(42956)] =
        {
            {type=0, name="MANA", cost=0.4, minCost=0.4, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(3566)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(53140)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49358)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(32272)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(3567)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(3563)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(35715)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(42897)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["PALADIN"] = {
        [GetSpellInfo(10326)] =
        {
            {type=0, name="MANA", cost=0.09, minCost=0.09, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48785)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48782)] =
        {
            {type=0, name="MANA", cost=0.29, minCost=0.29, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48801)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48950)] =
        {
            {type=0, name="MANA", cost=0.64, minCost=0.64, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["PRIEST"] = {
        [GetSpellInfo(10955)] =
        {
            {type=0, name="MANA", cost=0.9, minCost=0.9, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(32375)] =
        {
            {type=0, name="MANA", cost=0.33, minCost=0.33, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(8129)] = {
            {type=0, name="MANA", cost=0.14, minCost=0.14, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(64843)] =
        {
            {type=0, name="MANA", cost=0.63, minCost=0.63, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48071)] =
        {
            {type=0, name="MANA", cost=0.18, minCost=0.18, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(6064)] =
        {
            {type=0, name="MANA", cost=0.32, minCost=0.32, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48123)] =
        {
            {type=0, name="MANA", cost=0.15, minCost=0.15, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48063)] =
        {
            {type=0, name="MANA", cost=0.32, minCost=0.32, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48171)] =
        {
            {type=0, name="MANA", cost=0.6, minCost=0.6, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(2053)] =
        {
            {type=0, name="MANA", cost=0.27, minCost=0.27, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48072)] =
        {
            {type=0, name="MANA", cost=0.48, minCost=0.48, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48120)] =
        {
            {type=0, name="MANA", cost=0.27, minCost=0.27, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48135)] =
        {
            {type=0, name="MANA", cost=0.11, minCost=0.11, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(53023)] =
        {
            {type=0, name="MANA", cost=0.28, minCost=0.28, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48127)] =
        {
            {type=0, name="MANA", cost=0.17, minCost=0.17, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(605)] =
        {
            {type=0, name="MANA", cost=0.12, minCost=0.12, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(34914)] =
        {
            {type=0, name="MANA", cost=0.16, minCost=0.16, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["SHAMAN"] = {
        [GetSpellInfo(49273)] =
        {
            {type=0, name="MANA", cost=0.25, minCost=0.25, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49277)] =
        {
            {type=0, name="MANA", cost=0.72, minCost=0.72, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49276)] =
        {
            {type=0, name="MANA", cost=0.15, minCost=0.15, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(55459)] =
        {
            {type=0, name="MANA", cost=0.19, minCost=0.19, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(556)] =
        {
            {type=0, name="MANA", cost=0.05, minCost=0.05, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(6196)] =
        {
            {type=0, name="MANA", cost=0.03, minCost=0.03, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(60043)] =
        {
            {type=0, name="MANA", cost=0.1, minCost=0.1, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49238)] =
        {
            {type=0, name="MANA", cost=0.1, minCost=0.1, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(49271)] =
        {
            {type=0, name="MANA", cost=0.26, minCost=0.26, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(51514)] =
        {
            {type=0, name="MANA", cost=0.03, minCost=0.03, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
    ["WARLOCK"] = {
        [GetSpellInfo(18647)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48018)] =
        {
            {type=0, name="MANA", cost=0.15, minCost=0.15, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(126)] =
        {
            {type=0, name="MANA", cost=0.04, minCost=0.04, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(61191)] =
        {
            {type=0, name="MANA", cost=0.27, minCost=0.27, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(688)] =
        {
            {type=0, name="MANA", cost=0.64, minCost=0.64, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(697)] =
        {
            {type=0, name="MANA", cost=0.8, minCost=0.8, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47878)] =
        {
            {type=0, name="MANA", cost=0.53, minCost=0.53, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(60220)] =
        {
            {type=0, name="MANA", cost=0.54, minCost=0.54, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(58887)] =
        {
            {type=0, name="MANA", cost=0.8, minCost=0.8, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47888)] =
        {
            {type=0, name="MANA", cost=0.45, minCost=0.45, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47884)] =
        {
            {type=0, name="MANA", cost=0.68, minCost=0.68, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(17928)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47836)] =
        {
            {type=0, name="MANA", cost=0.34, minCost=0.34, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(6215)] =
        {
            {type=0, name="MANA", cost=0.12, minCost=0.12, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47825)] =
        {
            {type=0, name="MANA", cost=0.09, minCost=0.09, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47815)] =
        {
            {type=0, name="MANA", cost=0.08, minCost=0.08, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47827)] =
        {
            {type=0, name="MANA", cost=0.2, minCost=0.2, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47811)] =
        {
            {type=0, name="MANA", cost=0.17, minCost=0.17, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47838)] =
        {
            {type=0, name="MANA", cost=0.14, minCost=0.14, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(47809)] =
        {
            {type=0, name="MANA", cost=0.17, minCost=0.17, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(59172)] =
        {
            {type=0, name="MANA", cost=0.07, minCost=0.07, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(48181)] =
        {
            {type=0, name="MANA", cost=0.12, minCost=0.12, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
        [GetSpellInfo(30108)] =
        {
            {type=0, name="MANA", cost=0.15, minCost=0.15, costPercent=0, costPerSec=0, hasRequiredAura=false, requiredAuraID=0}
        },
    },
};


local SPCTable = {};

local function initialization_CostTable()
    local _, class =  UnitClass("player");
    local baseMana = UnitBaseMana("player") or 1

    if ( not DATACLASS[class] ) then
        return;
    end

    for spellName, costTable in pairs(DATACLASS[class]) do
        for key, costInfo in pairs(costTable) do
            SPCTable[spellName] = SPCTable[spellName] or {}
            SPCTable[spellName][key] = {};
            SPCTable[spellName][key].type = costInfo.type;
            SPCTable[spellName][key].name = costInfo.name;
            SPCTable[spellName][key].cost = costInfo.cost * baseMana;
            SPCTable[spellName][key].minCost = costInfo.minCost * baseMana;
            SPCTable[spellName][key].costPercent = costInfo.costPercent;
            SPCTable[spellName][key].hasRequiredAura = costInfo.hasRequiredAura;
            SPCTable[spellName][key].requiredAuraID = costInfo.requiredAuraID;
        end
    end
end

initialization_CostTable();

function GetSpellPowerCost(spellName)
    return SPCTable[spellName] or {};
end

local SPCHandler = CreateFrame("Frame")
SPCHandler:RegisterEvent("PLAYER_LEVEL_UP")
SPCHandler:SetScript("OnEvent", function()
    initialization_CostTable();
end)