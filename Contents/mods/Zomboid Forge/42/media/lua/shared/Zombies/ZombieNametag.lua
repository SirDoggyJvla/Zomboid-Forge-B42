--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Zombie nametag Lua object for ZomboidForge

]]--
--[[ ================================================ ]]--

-- requirements
local ZomboidForge = require "ZomboidForge_module"

-- caching
local CONFIGS = ZomboidForge.CONFIGS
local FONT_LIST = CONFIGS.FONT_LIST
local NAMETAG_LIST = ZomboidForge.NAMETAG_LIST
local XToScreen = IsoUtils.XToScreen
local YToScreen = IsoUtils.YToScreen
local getOffX = IsoCamera.getOffX
local getOffY = IsoCamera.getOffY
local core = getCore()

-- localy initialize player
local client_player = getPlayer()
local function initTLOU_OnGameStart(_, _)
	client_player = getPlayer()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)



ZomboidForge.ZombieNametag = {}
local ZombieNametag = ZomboidForge.ZombieNametag

-- Checks if the `zombie` is valid to have its nametag displayed for local player.
---@param zombie IsoZombie
---@param isBehind boolean
---@param isOnCursor boolean
---@return boolean
ZombieNametag.isValidForNametag = function(zombie,isBehind,isOnCursor)
    -- test for each options
    -- 1. draw nametag if should always be on
    if CONFIGS.AlwaysOn
    and (not isClient() or SandboxVars.ZomboidForge.NametagsAlwaysOn)
    and not isBehind and client_player:CanSee(zombie)
    then
        return true

    -- 2. don't draw if player can't see zombie
    elseif not client_player:CanSee(zombie)
    or isBehind
    then
        return false

    -- 3. draw if zombie is in radius of cursor detection
    elseif isOnCursor then
        return true

    -- 4. zombie is targeting client
    elseif CONFIGS.WhenZombieIsTargeting then
        local target = zombie:getTarget()
        if target and target == client_player then
            return true
        end
    end

    -- else return false, zombie is not valid
    return false
end

---Update the nametag, and tick down the counter based on current situation.
---@param valid boolean
---@param isBehind boolean
function ZombieNametag:update(valid,isBehind)
    if valid then
        self.tick = self.duration
    else
        if isBehind then
            self.tick = self.tick - 5
        else
            self.tick = self.tick - 1
        end
    end

    local tick = self.tick

    local zombie = self.zombie
    local textDrawObject = self.textDrawObject

    -- get initial position of zombie
    local x = zombie:getX()
    local y = zombie:getY()
    local z = zombie:getZ()

    local sx = XToScreen(x, y, z, 0)
    local sy = YToScreen(x, y, z, 0)

    -- apply offset
    sx = sx - getOffX() - zombie:getOffsetX()
    sy = sy - getOffY() - zombie:getOffsetY()

    -- apply client vertical placement
    sy = sy - 110 - 10*CONFIGS.VerticalOffset

    -- apply zoom level
    local zoom = core:getZoom(0)
    sx = sx / zoom
    sy = sy / zoom
    sy = sy - textDrawObject:getHeight()

    -- apply visuals
    local color = self.color
    local outline = self.outline
    textDrawObject:setDefaultColors(color[1]/255,color[2]/255,color[3]/255,tick/100)
    textDrawObject:setOutlineColors(outline[1]/255,outline[2]/255,outline[3]/255,tick/100)

    -- Draw nametag
    textDrawObject:AddBatchedDraw(sx, sy, true)

    if tick <= 0 then
        self:stop()
    end
end

---Stop handling this zombie's nametag.
function ZombieNametag:stop()
    NAMETAG_LIST[self.zombie] = nil
end

function ZombieNametag:new(zombie,ZombieTable)
	local o = {}
	setmetatable(o, self)
	self.__index = self

    -- main caracteristics
	o.zombie = zombie
    local duration = ZombieTable.nametagDuration or CONFIGS.NametagDuration
    o.duration = duration*60
    o.tick = duration*60

    -- create object
    local textDrawObject = TextDrawObject.new()

    -- apply string with font
    local font = CONFIGS.Font
    textDrawObject:ReadString(UIFont[FONT_LIST[font]], getText(ZombieTable.name), -1)

    -- visual
    o.color = ZombieTable.color or {255,255,255}
    o.outline = ZombieTable.outline or {255,255,255}
    if CONFIGS.Background then
        textDrawObject:setDrawBackground(true)
    end

    o.textDrawObject = textDrawObject


    --- DEBUG ---
    if isDebugEnabled() and ZomboidForge.DEBUG_ZombiePannel.RegisterNametags then
        print("New Nametag")
        print(getText(ZombieTable.name))
        for k,v in pairs(o) do
            print(tostring(k) .. ": "..tostring(v))
        end
    end

	return o
end