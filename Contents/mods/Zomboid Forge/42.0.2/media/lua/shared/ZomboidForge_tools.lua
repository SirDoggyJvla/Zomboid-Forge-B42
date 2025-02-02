--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Tools of ZomboidForge

]]--
--[[ ================================================ ]]--

-- requirements
local ZomboidForge = require "ZomboidForge_module"
local random = newrandom()

-- caching
local CONFIGS = ZomboidForge.CONFIGS


-- localy initialize player
local client_player = getPlayer()
local function initTLOU_OnGameStart(_, _)
	client_player = getPlayer()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)


--- RANDOM ---

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
-- Seeded random used in determining the `ZType` of a zombie.
---@param trueID        int
ZomboidForge.seededRand = function(trueID,max)
    trueID = trueID < 0 and -trueID or trueID
    local V = (trueID*A2 + A1) % D20
    V = (V*D20 + A2) % D40
    V = (V/D40) * max
    return V - V % 1 + 1
end




--- BOOLEAN HANDLER ---

ZomboidForge.SwapBoolean = function(boolean)
    if boolean then
        return false
    end

    return true
end

ZomboidForge.CountTrueInTable = function(tbl)
    local count = 0
    for _,v in pairs(tbl) do
        if type(v) == "boolean" and v then
            count = count + 1
        end
    end

    return count
end




--- TABLE TOOLS ---

ZomboidForge.RandomWeighted = function(tbl)
    -- get totalWeight
    local totalWeight = 0
    for _,v in pairs(tbl) do
        if type(v) ~= "number" then return tbl end
        totalWeight = totalWeight + v
    end

    -- chose a seeded random number based on max total weight
    local rand = random:random(0,totalWeight)

    -- test one by one each types and attribute if pass
    for k,v in pairs(tbl) do
        rand = rand - v
        if rand <= 0 then
            return k
        end
    end
end

-- Function to check if a table is an array
---@param t table
---@return boolean
ZomboidForge.isArray = function(t)
    -- Check if the table has only integer keys starting from 1 without gaps
    if type(t) ~= "table" then
        return false
    end

    -- Check for any non-integer keys that might exist outside the numeric sequence
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k % 1 ~= 0 or k < 1 then
            return false
        end
    end
    return true
end

-- Function to check if a table is a key table (dictionary)
---@param t table
---@return boolean
ZomboidForge.isKeyTable = function(t)
    if type(t) ~= "table" then
        return false
    end

    -- If we find any non-integer key, it's a key table (dictionary)
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k % 1 ~= 0 or k < 1 then
            return true
        end
    end

    return false
end

---Check if `value` is in `array`.
---@param array table
---@param value any
---@return boolean
ZomboidForge.IsInArray = function(array,value)
    for i = 1,#array do
        if array[i] == value then return true end
    end
    return false
end



--- STAT RETRIEVE TOOLS ---

---`data` can be a unique type or a table (array or key for weighted). If it's `nil` then return `nil`.
---Also compares to `current` and skip if data chosen is already `current`.
---@param data any
---@param female boolean
---@param current any
---@return any
ZomboidForge.ChoseInData = function(data,female,current)
    local data_type = type(data)

    -- try to fetch female/male specific data
    if data_type == "table" then
        data = female and data.female or not female and data.male or data
    end

    -- skip nil
    if data == nil then
        return nil

    -- handle unique data
    elseif type(data) ~= "table" then
        return data ~= current and data or nil

    -- handle single entry array
    elseif #data == 1 then
        data = data[1]
        return data ~= current and data or nil
    end

    -- handle array
    if ZomboidForge.isArray(data) then
        -- if current and ZomboidForge.IsInArray(data,current) then return nil end

        return data[random:random(1,#data)]
    end

    -- we actually want to force roll to make sure the percentages are right
    -- if data[current] then return nil end

    -- handle key table, which means weighted
    return ZomboidForge.RandomWeighted(data)
end



--- ZOMBIE TOOLS ---


-- Zombies that are around the client radius cursor will be valid to show their nametags.
-- This takes into account zombies on different levels.
---@return table
ZomboidForge.GetZOMBIES_ON_CURSOR = function(radius)
    local ZOMBIES_ON_CURSOR = {}

    local aiming = client_player:isAiming()
    if not CONFIGS.NoAimingNeeded and not aiming then return ZOMBIES_ON_CURSOR end

    -- get cursor coordinates
    local mouseX, mouseY = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), 0)
    mouseX = aiming and mouseX + 1.5 or mouseX
    mouseY = aiming and mouseY + 1.5 or mouseY

    -- TODO: this probably needs some tricks to optimize now that it checks for 65 levels instead of just 8
    for z = -32,32 do
        for x = mouseX - radius, mouseX + radius do
            for y = mouseY - radius, mouseY + radius do
                if (x - mouseX) * (x - mouseX) + (y - mouseY) * (y - mouseY) <= radius * radius then
                    local square = getSquare(x+ z*3, y+ z*3, z)
                    if square then
                        local movingObjects = square:getMovingObjects()
                        for i = 0, movingObjects:size() -1 do
                            local zombie = movingObjects:get(i)
                            if zombie and instanceof(zombie,"IsoZombie") then
                                ZOMBIES_ON_CURSOR[zombie] = true
                            end
                        end
                    end
                end
            end
        end
    end

    return ZOMBIES_ON_CURSOR
end



--- ZOMBIE COMBAT ---

ZomboidForge.SkipShotgunPellet = function(zombie)
    
end