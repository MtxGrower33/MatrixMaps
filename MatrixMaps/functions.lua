-- --==================================================
-- -- functions section
-- --==================================================

MMaps.f = {} -- for auto execute and performance monitoring
local MMaps = MMaps

-- hide stuff
function MMaps.f.HideStuff()
    MMaps.Debug("HideStuff() called")

    Minimap:SetClampedToScreen(true)

    MinimapBorder:Hide()
    MinimapBorderTop:Hide()

    MinimapZoomIn:ClearAllPoints()
    MinimapZoomIn:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 24, 21)

    MinimapZoomOut:ClearAllPoints()
    MinimapZoomOut:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -7)

    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 29, 5)

    MinimapZoneTextButton:ClearAllPoints()
    MinimapZoneTextButton:SetPoint("TOP", Minimap, "TOP", 0, 51)
    MinimapZoneTextButton:SetFrameStrata("HIGH")

    MinimapToggleButton:ClearAllPoints()
    MinimapToggleButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 25, 59)
end

-- minimap default position
function MMaps.f.SetDefaultPosition()
    local profile = MMaps.GetProfile()

    if not profile.defaultPositionSet then
        Minimap:ClearAllPoints()
        Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -72)
        Minimap:SetScale(1.0)
        profile.defaultPositionSet = true

        -- saave the default position into the profile
        profile.position = { point = "TOPRIGHT", relativePoint = "TOPRIGHT", xOffset = -50, yOffset = -72 }

        print("initialized default position")
    end
end

-- minimap visible
function MMaps.ToggleMinimap()
    local profile = MMaps.GetProfile()

    if Minimap:IsVisible() then
        Minimap:Hide()
        profile.minimap = false
        MMaps.Debug("Minimap hidden")
    else
        Minimap:Show()
        profile.minimap = true
        MMaps.Debug("Minimap shown")
    end
end

function MMaps.f.UpdateMinimap()
    local profile = MMaps.GetProfile()

    if profile.minimap then
        Minimap:Show()
        MMaps.Debug("UpdateMinimap(): shown")
    else
        Minimap:Hide()
        MMaps.Debug("UpdateMinimap(): hidden")
    end
end

-- minimap movable
function MMaps.ToggleMovable()
    local profile = MMaps.GetProfile()

    MMaps.Debug("Toggling minimap movable state.")

    if profile.movable then
        Minimap:SetMovable(false)
        Minimap:RegisterForDrag()
        Minimap:SetScript("OnDragStop", nil)
        profile.movable = false
    else
        Minimap:SetMovable(true)
        Minimap:RegisterForDrag("LeftButton")
        Minimap:SetScript("OnDragStart", function() Minimap:StartMoving() end)
        Minimap:SetScript("OnDragStop", function()
            Minimap:StopMovingOrSizing()
            local point, _, relativePoint, xOffset, yOffset = Minimap:GetPoint()
            profile.position = { point = point, relativePoint = relativePoint, xOffset = xOffset, yOffset = yOffset }
        end)
        profile.movable = true
    end
end

function MMaps.f.UpdateMovable()
    local profile = MMaps.GetProfile()

    MMaps.Debug("UpdateMovable() called")

    if profile.movable then
        Minimap:SetMovable(true)
        Minimap:RegisterForDrag("LeftButton")
        Minimap:SetScript("OnDragStart", function() Minimap:StartMoving() end)
        Minimap:SetScript("OnDragStop", function()
            Minimap:StopMovingOrSizing()
            local point, _, relativePoint, xOffset, yOffset = Minimap:GetPoint()
            profile.position = { point = point, relativePoint = relativePoint, xOffset = xOffset, yOffset = yOffset }
        end)
    else
        Minimap:SetMovable(false)
        Minimap:RegisterForDrag()
        Minimap:SetScript("OnDragStart", nil)
        Minimap:SetScript("OnDragStop", nil)
    end

    -- restore saved position if available
    if profile.position then
        Minimap:ClearAllPoints()
        Minimap:SetPoint(profile.position.point, UIParent, profile.position.relativePoint, profile.position.xOffset, profile.position.yOffset)
    end
end

-- minimap mousewheel zoom
function MMaps.ToggleZoom()
    local profile = MMaps.GetProfile()

    if profile.zoom then
        Minimap:EnableMouseWheel(false)
        Minimap:SetScript("OnMouseWheel", nil)
        profile.zoom = false
        MMaps.Debug("Minimap zoom disabled.")
    else
        Minimap:EnableMouseWheel(true)
        Minimap:SetScript("OnMouseWheel", function()
            local delta = arg1
            if delta > 0 then
                MinimapZoomIn:Click()
            else
                MinimapZoomOut:Click()
            end
        end)
        profile.zoom = true
        MMaps.Debug("Minimap zoom enabled.")
    end
end

function MMaps.f.UpdateZoom()
    local profile = MMaps.GetProfile()

    if profile.zoom then
        Minimap:EnableMouseWheel(true)
        Minimap:SetScript("OnMouseWheel", function()
            local delta = arg1
            if delta > 0 then
                MinimapZoomIn:Click()
            else
                MinimapZoomOut:Click()
            end
        end)
    else
        Minimap:EnableMouseWheel(false)
        Minimap:SetScript("OnMouseWheel", nil)
    end
    MMaps.Debug("Minimap zoom called")
end

-- minimap auto zoom out
local autoZoomTimer = 0
function MMaps.ToggleAutoZoomOut()
    local profile = MMaps.GetProfile()

    if profile.autoZoomOut then
        Minimap:SetScript("OnUpdate", nil)
        profile.autoZoomOut = false
    else
        autoZoomTimer = GetTime()
        Minimap:SetScript("OnUpdate", function()
            if GetTime() - autoZoomTimer >= 5 and this:GetZoom() > 0 then
                for i = 1, 5 do
                    MinimapZoomOut:Click()
                end
                autoZoomTimer = GetTime()
            end
        end)
        profile.autoZoomOut = true
    end
end

function MMaps.f.UpdateAutoZoomOut()
    local profile = MMaps.GetProfile()

    if profile.autoZoomOut then
        autoZoomTimer = GetTime()
        Minimap:SetScript("OnUpdate", function()
            if GetTime() - autoZoomTimer >= 5 and this:GetZoom() > 0 then
                for i = 1, 5 do
                    MinimapZoomOut:Click()
                end
                autoZoomTimer = GetTime()
            end
        end)
    else
        Minimap:SetScript("OnUpdate", nil)
    end
end

-- set minimap alpha
function MMaps.SetMinimapAlpha(value)
    local profile = MMaps.GetProfile()

    profile.minimapAlpha = value
    Minimap:SetAlpha(value)
    MMaps.Debug("Minimap alpha set to " .. value)
end

function MMaps.f.UpdateMinimapAlpha()
    local profile = MMaps.GetProfile()

    local alpha = profile.minimapAlpha or 1.0
    Minimap:SetAlpha(alpha)
    MMaps.Debug("Minimap alpha updated to " .. alpha)
end

-- -- set minimap scale
-- function MMaps.SetMinimapScale(value)
--     local profile = MMaps.GetProfile()

--     profile.minimapScale = value
--     Minimap:SetScale(value)
--     MMaps.Debug("Minimap scale set to " .. value)
-- end

-- function MMaps.f.UpdateMinimapScale()
--     local profile = MMaps.GetProfile()

--     local scale = profile.minimapScale or 1.0
--     Minimap:SetScale(scale)
--     MMaps.Debug("Minimap scale updated to " .. scale)
-- end

-- minimap shape
local mapShapes = {
    ["Round"] = "Textures\\MinimapMask",
    ["Square"] = "Interface\\BUTTONS\\WHITE8X8",
    ["Diamond"] = "Interface\\AddOns\\MatrixMaps\\shapes\\diamond",
    ["Hexagon"] = "Interface\\AddOns\\MatrixMaps\\shapes\\hexagon",
    ["Octagon"] = "Interface\\AddOns\\MatrixMaps\\shapes\\octagon",
    ["Heart"] = "Interface\\AddOns\\MatrixMaps\\shapes\\heart",
    ["Snowflak"] = "Interface\\AddOns\\MatrixMaps\\shapes\\snowflake",
    ["LLCorner"] = "Interface\\AddOns\\MatrixMaps\\shapes\\topright",
    ["LRCorner"] = "Interface\\AddOns\\MatrixMaps\\shapes\\topleft",
    ["ULCorner"] = "Interface\\AddOns\\MatrixMaps\\shapes\\bottomright",
    ["URCorner"] = "Interface\\AddOns\\MatrixMaps\\shapes\\bottomleft",
}

function MMaps.ToggleShape(shape)
    local profile = MMaps.GetProfile()

    if mapShapes[shape] then
        Minimap:SetMaskTexture(mapShapes[shape])
        profile.shape = shape
    else
        Minimap:SetMaskTexture(mapShapes["Round"])
        profile.shape = "Round"
    end
end

function MMaps.f.UpdateShape()
    local profile = MMaps.GetProfile()

    if mapShapes[profile.shape] then
        Minimap:SetMaskTexture(mapShapes[profile.shape])
    end
end

MMaps.mapShapes = mapShapes

function MMaps.GetNextShape(current)
    local keys = {}
    for k in pairs(mapShapes) do
        tinsert(keys, k)
    end
    table.sort(keys)

    for i = 1, getn(keys) do
        if keys[i] == current then
            return keys[mod(i, getn(keys)) + 1]
        end
    end

    return "Round"
end

-- minimap border
local borderFrame = CreateFrame("Frame", nil, Minimap)
borderFrame:SetPoint("CENTER", Minimap, "CENTER")
borderFrame:SetWidth(155)
borderFrame:SetHeight(155)
borderFrame:SetScale(1.02)

local borderTexture = borderFrame:CreateTexture(nil, "LOW")
borderTexture:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\border.tga")
borderTexture:SetAllPoints(borderFrame)
borderTexture:Hide()

function MMaps.ToggleBorder()
    local profile = MMaps.GetProfile()

    if profile.border == "Alternative" then
        borderTexture:Hide()
        profile.border = "None"
    else
        borderTexture:Show()
        profile.border = "Alternative"
    end
end

function MMaps.f.UpdateBorder()
    local profile = MMaps.GetProfile()

    if profile.border == "Alternative" then
        borderTexture:Show()
    else
        borderTexture:Hide()
    end
end

-- minimap extrabuttons (hide gametime, zoom, close)
function MMaps.HideGameTimeZoomClose()
    local profile = MMaps.GetProfile()

    if profile.gametimeZoomClose then
        GameTimeFrame:Hide()
        MinimapZoomIn:Hide()
        MinimapZoomOut:Hide()
        MinimapToggleButton:Hide()
        profile.gametimeZoomClose = false
    else
        GameTimeFrame:Show()
        MinimapZoomIn:Show()
        MinimapZoomOut:Show()
        MinimapToggleButton:Show()
        profile.gametimeZoomClose = true
    end
end

function MMaps.f.UpdateGameTimeZoomClose()
    local profile = MMaps.GetProfile()

    if profile.gametimeZoomClose then
        GameTimeFrame:Show()
        MinimapZoomIn:Show()
        MinimapZoomOut:Show()
        MinimapToggleButton:Show()
    else
        GameTimeFrame:Hide()
        MinimapZoomIn:Hide()
        MinimapZoomOut:Hide()
        MinimapToggleButton:Hide()
    end
end

-- minimap borderTop
local borderTopFrame = CreateFrame("Frame", nil, Minimap)
borderTopFrame:SetPoint("BOTTOM", Minimap, "TOP", 0, 7)
borderTopFrame:SetWidth(175)
borderTopFrame:SetHeight(64)
borderTopFrame:SetScale(1)

local borderTopTexture = borderTopFrame:CreateTexture(nil, "BACKGROUND")
borderTopTexture:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\borderTop.tga")
borderTopTexture:SetAllPoints(borderTopFrame)
borderTopTexture:Show()

function MMaps.ToggleBorderTop()
    local profile = MMaps.GetProfile()

    if profile.borderTop == "Alternative" then
        borderTopTexture:Hide()
        profile.borderTop = "None"
    else
        borderTopTexture:Show()
        profile.borderTop = "Alternative"
    end

end

function MMaps.f.UpdateBorderTop()
    local profile = MMaps.GetProfile()

    if profile.borderTop == "Alternative" then
        borderTopTexture:Show()
    else
        borderTopTexture:Hide()
    end
end

-- minimap rotating border
local math = math
local sin = math.sin
local cos = math.cos
local rad = math.rad

local rotatingTextures = {
    ["None"] = nil,
    ["Aura1"] = {path = "SPELLS\\AURARUNE256.BLP"},
    ["Aura2"] = {path = "SPELLS\\AuraRune256b.blp"},
    ["Aura3"] = {path = "SPELLS\\AuraRune_A.blp"},
    ["Aura4"] = {path = "SPELLS\\AuraRune_B.blp"},
    ["Glow1"] = {path = "PARTICLES\\GENERICGLOW5.BLP"},
    ["Glow2"] = {path = "SPELLS\\GENERICGLOW64.BLP"},
    ["Shock1"] = {path = "SPELLS\\Shockwave4.blp"},
    ["Shock2"] = {path = "World\\ENVIRONMENT\\DOODAD\\GENERALDOODADS\\ELEMENTALRIFTS\\Shockwave_blue.blp"},
    ["Shock3"] = {path = "SPELLS\\SHOCKWAVE_INVERTGREY.BLP"},
}

MMaps.RotatingFrame = nil
MMaps.RotationAngle = 0

local function CreateRotatingBorder(data)
    if not data then return end

    local profile = MMaps.GetProfile()
    local speed = profile.speed or 1
    local scale = profile.scale or 1
    local color = profile.color or { r = 1, g = 1, b = 1 }

    if MMaps.RotatingFrame then
        MMaps.RotatingFrame:Hide()
        MMaps.RotatingFrame:SetScript("OnUpdate", nil)
    end

    local frame = CreateFrame("Frame", nil, Minimap)
    frame:SetPoint("CENTER", Minimap, "CENTER")
    frame:SetWidth(155 * scale)
    frame:SetHeight(155 * scale)

    ---@class CustomTexture : Texture
    ---@field angle number
    local tex = frame:CreateTexture(nil, "BACKGROUND") ---@type CustomTexture
    tex:SetTexture(data.path)
    tex:SetAllPoints(frame)
    tex:SetBlendMode("ADD")
    tex:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
    tex:SetAlpha(data.a or 1)
    tex.angle = 0

    frame.texture = tex

    local function OnUpdate()
        tex.angle = (tex.angle or 0) + speed
        if tex.angle > 360 then tex.angle = tex.angle - 360 end
        local s = sin(rad(tex.angle))
        local c = cos(rad(tex.angle))
        tex:SetTexCoord(
            0.5 - s, 0.5 + c,
            0.5 + c, 0.5 + s,
            0.5 - c, 0.5 - s,
            0.5 + s, 0.5 - c
        )
    end

    frame:SetScript("OnUpdate", OnUpdate)

    MMaps.RotatingFrame = frame

    -- FPS limiter
    if profile.fpsLimit ~= false then
        local fpsMonitor = CreateFrame("Frame")
        fpsMonitor:SetScript("OnUpdate", function()
            if GetFramerate() < 30 and frame:GetScript("OnUpdate") then
                frame:SetScript("OnUpdate", nil)
            elseif GetFramerate() >= 30 and not frame:GetScript("OnUpdate") then
                frame:SetScript("OnUpdate", OnUpdate)
            end
        end)
    end
end

function MMaps.ToggleRotatingBorder()
    local profile = MMaps.GetProfile()

    local keys = { "None", "Aura1", "Aura2", "Aura3", "Aura4", "Glow1", "Glow2", "Shock1", "Shock2", "Shock3", }

    ---@diagnostic disable-next-line: deprecated
    for i = 1, table.getn(keys) do
        if keys[i] == profile.rotatingBorder then
    ---@diagnostic disable-next-line: deprecated
            profile.rotatingBorder = keys[mod(i, table.getn(keys)) + 1]
            MMaps.f.UpdateRotatingBorder()
            return
        end
    end

    profile.rotatingBorder = keys[1] -- default to first key if no match is found

    MMaps.f.UpdateRotatingBorder()
end

function MMaps.f.UpdateRotatingBorder()
    local profile = MMaps.GetProfile()
    local setting = rotatingTextures[profile.rotatingBorder]

    if MMaps.RotatingFrame then
        MMaps.RotatingFrame:Hide()
        MMaps.RotatingFrame:SetScript("OnUpdate", nil)
        MMaps.RotatingFrame = nil
    end

    if setting then
        CreateRotatingBorder(setting)
        MMaps.f.UpdateRotatingSpeed()
        MMaps.f.UpdateRotatingScale()
    end
end

function MMaps.SetRotatingSpeed(value)
    value = math.min(20, math.max(-20, value))

    local profile = MMaps.GetProfile()
    profile.speed = value

    MMaps.f.UpdateRotatingBorder()
end

function MMaps.f.UpdateRotatingSpeed()
    local profile = MMaps.GetProfile()

    if MMaps.RotatingFrame and profile.speed then
        local speed = profile.speed
        local tex = MMaps.RotatingFrame.texture

        if tex then
            local function OnUpdate()
                tex.angle = (tex.angle or 0) + speed
                if tex.angle > 360 then tex.angle = tex.angle - 360 end
                local s = sin(rad(tex.angle))
                local c = cos(rad(tex.angle))
                tex:SetTexCoord(
                    0.5 - s, 0.5 + c,
                    0.5 + c, 0.5 + s,
                    0.5 - c, 0.5 - s,
                    0.5 + s, 0.5 - c
                )
            end

            MMaps.RotatingFrame:SetScript("OnUpdate", OnUpdate)
        end
    end
end

function MMaps.SetRotatingScale(value)
    value = math.min(3, math.max(0.1, value))

    local profile = MMaps.GetProfile()
    profile.scale = value

    MMaps.f.UpdateRotatingBorder()
end

function MMaps.f.UpdateRotatingScale()
    local profile = MMaps.GetProfile()

    if MMaps.RotatingFrame and profile.scale then
        local scale = profile.scale
        MMaps.RotatingFrame:SetWidth(155 * scale)
        MMaps.RotatingFrame:SetHeight(155 * scale)
    end
end

function MMaps.ToggleTexColour()
    local profile = MMaps.GetProfile()
    local colors = {
        -- Warm colors
        { r = 1, g = 0, b = 0 },           -- Red
        { r = 1, g = 0.5, b = 0 },         -- Orange
        { r = 1, g = 1, b = 0 },           -- Yellow
        { r = 1, g = 0.84, b = 0 },        -- Golden
        { r = 0.72, g = 0.45, b = 0.2 },   -- Bronze
        { r = 0.85, g = 0.44, b = 0.84 },  -- Orchid
        { r = 1, g = 0.41, b = 0.38 },     -- Coral

        -- Cooler metallics
        { r = 0.5, g = 0.5, b = 0.5 },     -- Silver
        { r = 0.75, g = 0.75, b = 0.75 },  -- Light Silver
        { r = 0.3, g = 0.3, b = 0.3 },     -- Dark Metal

        -- Cool colors
        { r = 0, g = 1, b = 0 },           -- Green
        { r = 0.18, g = 0.55, b = 0.34 },  -- Sea Green
        { r = 0, g = 0, b = 1 },           -- Blue
        { r = 0.25, g = 0.41, b = 0.88 },  -- Royal Blue
        { r = 0.58, g = 0, b = 0.83 },     -- Royal Purple
        { r = 0.5, g = 0, b = 0.5 },       -- Purple
        { r = 0.93, g = 0.51, b = 0.93 },  -- Lavender Blush
        { r = 0.68, g = 0.85, b = 0.9 },   -- Light Blue
        { r = 0.13, g = 0.7, b = 0.67 },   -- Teal
    }

    if not profile.colorIndex then
        profile.colorIndex = 1
    else
        profile.colorIndex = profile.colorIndex + 1
    ---@diagnostic disable-next-line: deprecated
        if profile.colorIndex > table.getn(colors) then
            profile.colorIndex = 1
        end
    end

    profile.color = colors[profile.colorIndex]
    MMaps.f.UpdateRotatingBorder()
end

function MMaps.f.UpdateTexColour()
    local profile = MMaps.GetProfile()

    if MMaps.RotatingFrame and profile.color then
        local color = profile.color
        local tex = MMaps.RotatingFrame.texture

        if tex then
            tex:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
        end
    end
end

function MMaps.ToggleFPSLimit()
    local profile = MMaps.GetProfile()

    StaticPopupDialogs["MMAPS_RELOAD_UI"] = {
        text = "FPS Limit needs a reload. Continue?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            profile.fpsLimit = not profile.fpsLimit
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local popup = StaticPopup_Show("MMAPS_RELOAD_UI")
    if popup then
        popup:SetFrameStrata("TOOLTIP")
        popup:ClearAllPoints()
        popup:SetPoint("TOP", UIParent, "TOP", 0, -50)
    end
end

MMaps.rotatingTextures = rotatingTextures

-- snowfall system
local snowfall = CreateFrame("Frame", nil, Minimap)
snowfall:SetPoint("CENTER", Minimap, "CENTER", 0, -30)
snowfall:SetWidth(210)
snowfall:SetHeight(250)

local flakes = {}
local lastSpawnTime = 0
local nextSpawnDelay = 0

local function CreateSnowflake()
    local flake = CreateFrame("Frame", nil, snowfall)
    local size = 4 + math.random(0, 4)
    flake:SetWidth(size)
    flake:SetHeight(size)

    local tex = flake:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\snow.tga")
    tex:SetAllPoints(flake)
    flake.texture = tex

    flake.baseX = math.random(0, snowfall:GetWidth())
    flake.x = flake.baseX
    flake.y = snowfall:GetHeight()
    flake.speed = 10 + math.random(0, 20)

    flake.wobbleAmplitude = 2 + math.random() * 2
    flake.wobbleSpeed = 1 + math.random() * 5.5
    flake.wobbleAngle = math.random() * 6.28

    flake.spawnTime = GetTime()

    flake:Show()
    table.insert(flakes, flake)
end

local function SnowfallOnUpdate()
    local profile = MMaps.GetProfile()
    local snowEnabled = profile.snowEnabled

    if not snowEnabled then return end

    local now = GetTime()

    -- spawn snowflakes with random interval
    if now - lastSpawnTime > nextSpawnDelay then
        if math.random(0, 100) > 40 then  -- spawn chance
            CreateSnowflake()
        end
        lastSpawnTime = now
        nextSpawnDelay = 0.45 + math.random() * 0.15
    end

    -- move snowflakes and remove out of bounds
    local i = 1
    ---@diagnostic disable-next-line: deprecated
    while i <= table.getn(flakes) do
        local flake = flakes[i]
        local dt = now - flake.spawnTime
        flake.spawnTime = now

        flake.y = flake.y - flake.speed * dt

        -- wobble effect
        flake.wobbleAngle = flake.wobbleAngle + flake.wobbleSpeed * dt
        local wobbleOffset = math.sin(flake.wobbleAngle) * flake.wobbleAmplitude
        flake.x = flake.baseX + wobbleOffset

        -- fade snowflakes near the bottom
        local fadeStart = snowfall:GetHeight() * 0.1
        if flake.y < fadeStart then
            local alpha = flake.y / fadeStart
            flake.texture:SetAlpha(alpha)
        end

        -- update snowflake position
        flake:SetPoint("TOPLEFT", snowfall, "BOTTOMLEFT", flake.x, flake.y)

        -- remove snowflakes if they go out of bounds
        if flake.y < 0 or flake.x < 0 or flake.x > snowfall:GetWidth() then
            flake:Hide()
            table.remove(flakes, i)
        else
            i = i + 1
        end
    end
end

snowfall:SetScript("OnUpdate", SnowfallOnUpdate)

-- FPS limiter for snowfall
local fpsMonitor = CreateFrame("Frame")
fpsMonitor:SetScript("OnUpdate", function()
    local profile = MMaps.GetProfile()

    if profile.fpsLimit then
        if GetFramerate() < 30 and snowfall:GetScript("OnUpdate") then
            snowfall:SetScript("OnUpdate", nil)
        elseif GetFramerate() >= 30 and not snowfall:GetScript("OnUpdate") then
            snowfall:SetScript("OnUpdate", SnowfallOnUpdate)
        end
    end
end)

-- toggle the snowfall system
function MMaps.ToggleSnowfall()
    local profile = MMaps.GetProfile()
    local snowEnabled = profile.snowEnabled

    if snowEnabled then
        profile.snowEnabled = false
        snowfall:Hide()
    else
        profile.snowEnabled = true
        snowfall:Show()
    end
end

-- update snowfall visibility based on profile
function MMaps.f.UpdateSnowfall()
    local profile = MMaps.GetProfile()
    local snowEnabled = profile.snowEnabled

    if snowEnabled then
        snowfall:Show()
    else
        snowfall:Hide()
    end
end

-- --==================================================
-- -- monitor section
-- --==================================================

-- execute all funcs
function MMaps.executeAllFunctions()
    MMaps.Debug("Loading modules…")

    for _, func in pairs(MMaps.f) do
        func()
    end
end

-- monitor
local monitor = false

if monitor then
    local GetTime = GetTime -- Localize frequent calls
    local gcinfo = gcinfo

    -- Profile wrapper function
    local function profile(func, name)
        return function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
            local startTime = GetTime()
            local startMem = gcinfo()
            local results = {func(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)}
            local deltaTime = GetTime() - startTime
            local deltaMem = gcinfo() - startMem

            -- Report results (adjust output as needed)
            print(
                string.format(
                    "[PROFILER] %s: Time = %.3fs | Memory = %d KB",
                    name,
                    deltaTime,
                    deltaMem
                )
            )
            return unpack(results)
        end
    end

    -- Wrap all functions in the "f" table
    for name, func in pairs(MMaps.f) do
        if type(func) == "function" then
            MMaps.f[name] = profile(func, name)
        end
    end
end

-- -- next feature: lets see lol