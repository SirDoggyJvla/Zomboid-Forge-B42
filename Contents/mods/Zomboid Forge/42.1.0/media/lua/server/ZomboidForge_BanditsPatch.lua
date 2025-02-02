--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Patch to Bandits to finally fix Bandits having the ZType visuals and stats.

]]--
--[[ ================================================ ]]--

if not getActivatedMods():contains("\\Bandits") then return end

require "BanditClientCommands"

BanditServer.Commands.SpawnGroup = function(player, event)
    local radius = 0.5
    local knockedDown = false
    local crawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local isInvulnerable = false
    local isSitting = false
    local gmd = GetBanditModData()

    local gx = event.x
    local gy = event.y
    local gz = event.z or 0

    local event_bandits = event.bandits
    for i = 1, #event_bandits do
        local bandit = event_bandits[i]
        if #event.bandits > 1 then
            gx = ZombRand(gx - radius, gx + radius + 1)
            gy = ZombRand(gy - radius, gy + radius + 1)
        end

        local zombieList = BanditCompatibility.AddZombiesInOutfit(gx, gy, gz, bandit.outfit, bandit.femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, isInvulnerable, isSitting, bandit.health)
        for i=0, zombieList:size()-1 do
            local zombie = zombieList:get(i)
            local id = BanditUtils.GetCharacterID(zombie)

            zombie:setHealth(bandit.health)

            -- clients will change that flag to true once they recognize the bandit by its ID
            zombie:setVariable("Bandit", false)

            -- just in case
            zombie:setPrimaryHandItem(nil)
            zombie:setSecondaryHandItem(nil)
            zombie:clearAttachedItems()

            local brain = {}

            -- unique bandit id based on outfit
            brain.id = id

            -- time of birth
            brain.born = getGameTime():getWorldAgeHours()

            -- the player that spawned the bandit becomes his master, 
            -- this plays a role in particular programs like Companion
            brain.master = BanditUtils.GetCharacterID(player)

            -- for keyring
            brain.fullname = BanditNames.GenerateName(zombie:isFemale())

            -- which voice to use
            brain.voice = Bandit.PickVoice(zombie)

            -- hostility towards human players
            brain.hostile = event.hostile

            -- copy clan abilities to the bandit
            brain.clan = bandit.clan
            brain.eatBody = bandit.eatBody
            brain.accuracyBoost = bandit.accuracyBoost

            -- hair style
            if bandit.hairStyle then
                brain.hairStyle = bandit.hairStyle
            end

            -- the AI program to follow at start
            brain.program = {}
            brain.program.name = event.program.name
            brain.program.stage = event.program.stage

            -- random DNA
            local dna = {}
            dna.slow = BanditUtils.CoinFlip()
            dna.blind = BanditUtils.CoinFlip()
            dna.sneak = BanditUtils.CoinFlip()
            dna.unfit = BanditUtils.CoinFlip()
            dna.coward = BanditUtils.CoinFlip()
            brain.dna = dna

            -- program specific capabilities independent from clan
            -- brain.capabilities = ZombiePrograms[event.program.name].GetCapabilities()

            -- action and state flags
            brain.stationary = false
            brain.sleeping = false
            brain.aiming = false
            brain.moving = false
            brain.endurance = 1.00
            brain.speech = 0.00
            brain.sound = 0.00
            brain.infection = 0

            -- inventory
            brain.weapons = bandit.weapons
            brain.loot = bandit.loot
            brain.key = bandit.key
            brain.inventory = {}
            table.insert(brain.inventory, "weldingGear")
            table.insert(brain.inventory, "crowbar")
            
            -- empty task table, will be populated during bandit life
            brain.tasks = {}

            -- not used
            brain.world = {}

            -- print ("[INFO] Bandit " .. brain.fullname .. "(".. id .. ") from clan " .. bandit.clan .. " in outfit " .. bandit.outfit .. " has joined the game.")
            gmd.Queue[id] = brain

            zombie:getModData().IsBandit = true
        end
    end
end