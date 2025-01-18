--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file allows players to activate the base zombies.

]]--
--[[ ================================================ ]]--

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"

-- Modders can overwrite this to stop Zomboids from being ever activated by other players
ZomboidForge.AddZomboids = function(ZTypes)
    ZTypes.ZF_Zomboid = {
        -- base informations
        name = "IGUI_ZF_Zomboid",
        chance = SandboxVars.ZomboidForge.ZomboidChance,

        -- stats
        walkType = ZomboidForge.SpeedOptionToWalktype[SandboxVars.ZomboidForge.ZomboidWalktype],
        strength = SandboxVars.ZomboidForge.ZomboidStrength,
        toughness = SandboxVars.ZomboidForge.ZomboidToughness,
        cognition = SandboxVars.ZomboidForge.ZomboidCognition,
        memory = SandboxVars.ZomboidForge.ZomboidMemory,
        sight = SandboxVars.ZomboidForge.ZomboidVision,
        hearing = SandboxVars.ZomboidForge.ZomboidHearing,

        -- UI
        color = {255, 255, 255,},
        outline = {0, 0, 0,},
    }
end