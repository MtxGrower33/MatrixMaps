-- mainframe
local gui = CreateFrame("Frame", "MMapsGUI", UIParent)
gui:SetWidth(330)
gui:SetHeight(650)
gui:SetPoint("CENTER", 0, 0)
gui:SetMovable(true)
gui:EnableMouse(true)
gui:SetClampedToScreen(true)
gui:SetFrameStrata("DIALOG")
gui:SetScale(0.8)
gui:SetToplevel(true)
gui:SetClampedToScreen(true)
gui:SetFrameLevel(10)
gui:RegisterForDrag("LeftButton")
gui:SetScript("OnMouseDown", function() this:StartMoving() end)
gui:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
gui:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
gui:SetBackdropColor(0, 0, 0, 1)
gui:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
tinsert(UISpecialFrames, gui:GetName())
gui:Hide()

-- helpers
local function CreateButton(parent, width, height, point, text, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(height)
    button:SetPoint(unpack(point))
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

-- title
local title = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText("MatrixMaps")
title:SetPoint("TOP", 0, -20)
title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
title:SetTextColor(1, 1, 1, 1)

-- section headers
local titleFunc = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
titleFunc:SetText("Functions")
titleFunc:SetPoint("TOP", 0, -65)

local line = gui:CreateTexture(nil, "ARTWORK")
line:SetTexture("Interface\\Buttons\\WHITE8x8")
line:SetWidth(gui:GetWidth() - 30)
line:SetHeight(3)
line:SetPoint("BOTTOM", 0, 180)
line:SetVertexColor(0.2, 0.2, 0.2, 1)

local line2 = gui:CreateTexture(nil, "ARTWORK")
line2:SetTexture("Interface\\Buttons\\WHITE8x8")
line2:SetWidth(gui:GetWidth() - 30)
line2:SetHeight(3)
line2:SetPoint("TOP", 0, -50)
line2:SetVertexColor(0.2, 0.2, 0.2, 1)

local titleProf = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
titleProf:SetText("Profiles")
titleProf:SetPoint("BOTTOM", 0, 140)

-- buttons
local function SetTooltip(button, text)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end
local function CreateButtonWithTooltip(parent, width, height, point, tooltipText, onClick)
    local btn = CreateButton(parent, width, height, point, "", onClick)
    SetTooltip(btn, tooltipText)
    return btn
end
local function PlaceButton(button, col, row, yOffset)
    local x = 20 + (col - 1) * 150
    local y = -50 - ((row - 1) * 32) - yOffset
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", gui, "TOPLEFT", x, y)
end

-- function buttons
local btn1 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Minimap permanently", function()
    MMaps.ToggleMinimap()
    MMaps.GUI_Update()
end)
local btn2 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Movable Minimap", function()
    MMaps.ToggleMovable()
    MMaps.GUI_Update()
end)
local btn3 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Mousewheel Zooming", function()
    MMaps.ToggleZoom()
    MMaps.GUI_Update()
end)
local btn4 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Auto Zoom Out after 5 seconds", function()
    MMaps.ToggleAutoZoomOut()
    MMaps.GUI_Update()
end)
local btn5 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Change Minimap Shape", function()
    local profile = MMaps.GetProfile()
    local nextShape = MMaps.GetNextShape(profile.shape)
    MMaps.ToggleShape(nextShape)
    MMaps.GUI_Update()
end)
local btn6 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Compass Indicators", function()
    MMaps.ToggleBorder()
    MMaps.GUI_Update()
end)
local btn7 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Extra Buttons", function()
    MMaps.HideGameTimeZoomClose()
    MMaps.GUI_Update()
end)
local btn8 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Top Texture", function()
    MMaps.ToggleBorderTop()
    MMaps.GUI_Update()
end)
local btn9 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Rotating Texture", function()
    MMaps.ToggleRotatingBorder()
    MMaps.GUI_Update()
end)
local btn10 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Adjust Rotating Speed", function()
    local profile = MMaps.GetProfile()
    profile.speed = (profile.speed or -5) + 0.2
    if profile.speed > 5 then
        profile.speed = -5
    end
    MMaps.SetRotatingSpeed(profile.speed)
    MMaps.GUI_Update()
end)
local btn11 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle FPS Limiter - Pause all animations when FPS below 30", function()
    MMaps.ToggleFPSLimit()
end)
local btn12 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Adjust Rotating Scale", function()
    local profile = MMaps.GetProfile()
    profile.scale = (profile.scale or -3) + 0.2
    if profile.scale > 3 then
        profile.scale = -3
    end
    MMaps.SetRotatingScale(profile.scale)
    MMaps.GUI_Update()
end)
local btn13 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Texture Color - 19 colours", function()
    MMaps.ToggleTexColour()
    MMaps.GUI_Update()
end)
local btn14 = CreateButtonWithTooltip(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Toggle Snowfall Effect", function()
    MMaps.ToggleSnowfall()
    MMaps.GUI_Update()
end)

-- profile buttons
local function GetNextProfileName()
    local current = MMaps_DB.current
    local keys = {}
    for k in pairs(MMaps_DB.profiles) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local nextIndex = 1
    for i = 1, getn(keys) do
        if keys[i] == current then
            nextIndex = i + 1
            break
        end
    end
    if nextIndex > getn(keys) then
        nextIndex = 1
    end
    return keys[nextIndex]
end
local function GetNextAvailableProfile()
    for i = 1, 3 do
        local name = "Profile " .. i
        if not MMaps_DB.profiles[name] then
            return name
        end
    end
    return nil
end
local function CountCustomProfiles()
    local count = 0
    for i = 1, 3 do
        if MMaps_DB.profiles["Profile " .. i] then
            count = count + 1
        end
    end
    return count
end

-- create profile button
local btn15 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Create Profile", function()
    if CountCustomProfiles() >= 3 then
        return
    end

    local name = GetNextAvailableProfile()
    if name then
        MMaps.CreateProfile(name)
        MMaps.SwitchProfile(name)
    end

    MMaps.GUI_Update()
end)
local btn16 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 0, 0}, "Switch Profile", function()
    local next = GetNextProfileName()
    MMaps.SwitchProfile(next)
    MMaps.GUI_Update()
end)
local btn17 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 140, -10}, "Delete Profile", function()
    local current = MMaps_DB.current
    MMaps.DeleteProfile(current)
    MMaps.GUI_Update()
end)

-- function area
PlaceButton(btn1, 1, 1, 60)
PlaceButton(btn2, 1, 3, 90)
PlaceButton(btn3, 1, 4, 90)
PlaceButton(btn4, 1, 5, 90)
PlaceButton(btn6, 1, 7, 120)
PlaceButton(btn7, 1, 6, 120)
PlaceButton(btn8, 1, 8, 120)
PlaceButton(btn11,1, 2, 60)

PlaceButton(btn5, 2, 3, 90)
PlaceButton(btn9, 2, 4, 90)
PlaceButton(btn10,2, 5, 90)
PlaceButton(btn12,2, 6, 120)
PlaceButton(btn13,2, 7, 120)
PlaceButton(btn14,2, 8, 120)
-- profile area
PlaceButton(btn15, 1, 11, 160)
PlaceButton(btn16, 1, 12, 160)
PlaceButton(btn17, 1, 13, 160)

-- additional text for current profile
local currentProfileLabel
local function CreateCurrentProfileLabel(parent)
    if not currentProfileLabel then
        currentProfileLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        currentProfileLabel:SetPoint("BOTTOM", 75, 37)
        currentProfileLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    end
    return currentProfileLabel
end

-- update gui
function MMaps.GUI_Update()
    local profile = MMaps.GetProfile()

    if not currentProfileLabel then
        currentProfileLabel = CreateCurrentProfileLabel(gui)
    end
    currentProfileLabel:SetText("Current Profile:\n\n|cff00ff00" .. (profile.name or "Unknown") .. "|r\n\n\nMax. 3 Profiles")
    currentProfileLabel:SetJustifyH("RIGHT")

    btn1:SetText("Minimap: " .. (profile.minimap and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn2:SetText("Movable: " .. (profile.movable and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn3:SetText("Mousezoom: " .. (profile.zoom and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn4:SetText("Zoom Out: " .. (profile.autoZoomOut and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn14:SetText("Snowfall: " .. (profile.snowEnabled and "|cff00ff00ON|r" or "|cffff0000OFF|r"))

    btn5:SetText("Shape: " .. (profile.shape or "Round"))
    btn6:SetText("NESW: " .. (profile.border and profile.border ~= "None" and "|cff00ff00" .. profile.border .. "|r" or "|cffff0000OFF|r"))
    btn7:SetText("Extra Buttons: " .. (profile.gametimeZoomClose and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn8:SetText("Top: " .. (profile.borderTop and profile.borderTop ~= "None" and "|cff00ff00" .. profile.borderTop .. "|r" or "|cffff0000OFF|r"))
    btn9:SetText("Texture: " .. (profile.rotatingBorder and profile.rotatingBorder ~= "None" and "|cff00ff00" .. profile.rotatingBorder .. "|r" or "|cffff0000OFF|r"))
    btn10:SetText("Speed: " .. (profile.speed and "|cff00ff00" .. profile.speed .. "|r" or "|cffff0000OFF|r"))
    btn11:SetText("|cffffffffFPS Limit|r: " .. (profile.fpsLimit and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    btn12:SetText("Scale: " .. (profile.scale and "|cff00ff00" .. profile.scale .. "|r" or "|cffff0000OFF|r"))
    if profile.color then
        btn13:SetText("Color: |cff" .. string.format("%02x%02x%02x", profile.color.r * 255, profile.color.g * 255, profile.color.b * 255) .. "RGB|r")
    else
        btn13:SetText("Color: |cffff0000OFF|r")
    end
end

-- Minimap shift+rightclick to open GUI
if not Minimap.hookScript then
    function Minimap:hookScript(event, func)
        local oldScript = self:GetScript(event)
        self:SetScript(event, function()
            if oldScript then oldScript() end
            func()
        end)
    end
end
Minimap:hookScript("OnMouseUp", function()
    if arg1 == "RightButton" and IsShiftKeyDown() then
        if gui:IsShown() then
            gui:Hide()
        else
            gui:ClearAllPoints() -- Reset position
            gui:SetPoint("CENTER", 0, 0) -- Center the GUI
            gui:Show()
            MMaps.GUI_Update()
        end
    end
end)

-- slash command
SLASH_MMAPSGUI1 = "/mmaps"
SlashCmdList["MMAPSGUI"] = function()
    if gui:IsShown() then
        gui:Hide()
    else
        gui:ClearAllPoints() -- Reset position
        gui:SetPoint("CENTER", 0, 0) -- Center the GUI
        gui:Show()
        MMaps.GUI_Update()
    end
end

-- end