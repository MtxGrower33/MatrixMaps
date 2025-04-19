--==================================================
-- Main GUI Frame
--==================================================
-- GUI Helpers      Section
-- Profile Helpers  Section
-- GUI Layout       Section
-- Elements         Section
-- GUI Labels       Section
-- Events           Section
--==================================================

local gui = CreateFrame("Frame", "MMapsGUI", UIParent)
gui:SetWidth(495)
gui:SetHeight(600)
gui:SetPoint("CENTER", 0, 0)
gui:SetMovable(true)
gui:EnableMouse(true)
gui:SetClampedToScreen(true)
gui:SetToplevel(true)
gui:SetFrameLevel(10)
gui:SetFrameStrata("DIALOG")
gui:SetScale(0.8)
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

-- --==================================================
-- -- GUI Helpers Section
-- --==================================================

local function CreateButton(parent, width, height, point, text, onClick, tooltipText)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(width)
    b:SetHeight(height)
    b:SetPoint(unpack(point))
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    if tooltipText then
        b:SetScript("OnEnter", function()
            GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    return b
end

local function CreateTitle(text, anchorPoint, x, y, size)
    local title = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetText(text)
    title:SetPoint(anchorPoint, x or 0, y or 0)
    title:SetFont("Fonts\\FRIZQT__.TTF", size or 16, "OUTLINE")
    title:SetTextColor(1, 1, 1, 1)
    return title
end

local function CreateLine(anchor, x, y)
    local line = gui:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8x8")
    line:SetWidth(gui:GetWidth() - 30)
    line:SetHeight(3)
    line:SetPoint(anchor, x or 0, y or 0)
    line:SetVertexColor(0.2, 0.2, 0.2, 1)
end

-- --==================================================
-- -- GUI Layout Section
-- --==================================================

CreateTitle("MatrixMaps", "TOP", 0, -20)
CreateTitle("Functions", "TOP", 0, -65)
CreateTitle("Profiles", "BOTTOM", 0, 70)
CreateLine("TOP", 0, -50)
CreateLine("BOTTOM", 0, 100)

-- --==================================================
-- -- Elements Section
-- --==================================================

local btn1 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -110}, "", function()
    MMaps.ToggleMinimap()
    MMaps.GUI_Update()
end, "Toggle Minimap permanently")

local btn2 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -200}, "", function()
    MMaps.ToggleMovable()
    MMaps.GUI_Update()
end, "Toggle Movable Minimap")

local btn3 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -230}, "", function()
    MMaps.ToggleZoom()
    MMaps.GUI_Update()
end, "Toggle Mousewheel Zooming")

local btn4 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -260}, "", function()
    MMaps.ToggleAutoZoomOut()
    MMaps.GUI_Update()
end, "Toggle Auto Zoom Out after 5 seconds")

local btn5 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -320}, "", function()
    local profile = MMaps.GetProfile()
    local nextShape = MMaps.GetNextShape(profile.shape)
    MMaps.ToggleShape(nextShape)
    MMaps.GUI_Update()
end, "Change Minimap Shape")

local btn6 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -350}, "", function()
    MMaps.ToggleBorder()
    MMaps.GUI_Update()
end, "Toggle Compass Indicators")

local btn7 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -290}, "", function()
    MMaps.HideGameTimeZoomClose()
    MMaps.GUI_Update()
end, "Toggle Extra Buttons")

local btn8 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -320}, "", function()
    MMaps.ToggleBorderTop()
    MMaps.GUI_Update()
end, "Toggle Top Texture")

local btn9 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -290}, "", function()
    MMaps.ToggleRotatingBorder()
    MMaps.GUI_Update()
end, "Toggle Rotating Texture")

local btn10 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -260}, "", function()
    local profile = MMaps.GetProfile()
    profile.speed = (profile.speed or -5) + 0.2
    if profile.speed > 5 then
        profile.speed = -5
    end
    MMaps.SetRotatingSpeed(profile.speed)
    MMaps.GUI_Update()
end, "Adjust Rotating Speed")

local btn11 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 30, -140}, "", function()
    MMaps.ToggleFPSLimit()
end, "Toggle FPS Limiter - Pause all animations when FPS below 30")

local btn12 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -230}, "", function()
    local profile = MMaps.GetProfile()
    profile.scale = (profile.scale or -3) + 0.2
    if profile.scale > 3 then
        profile.scale = -3
    end
    MMaps.SetRotatingScale(profile.scale)
    MMaps.GUI_Update()
end, "Adjust Rotating Scale")

local btn13 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -200}, "", function()
    MMaps.ToggleTexColour()
    MMaps.GUI_Update()
end, "Toggle Texture Color - 19 colours")

local btn14 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -140}, "", function()
    MMaps.ToggleSnowfall()
    MMaps.GUI_Update()
end, "Toggle Snowfall Effect")

local btn15 = CreateButton(gui, 130, 24, {"TOPLEFT", gui, "TOPLEFT", 180, -350}, "", function()
    local profile = MMaps.GetProfile()
    profile.minimapAlpha = (profile.minimapAlpha or 0) + 0.1
    if profile.minimapAlpha > 1 then
        profile.minimapAlpha = 0
    end
    MMaps.SetMinimapAlpha(profile.minimapAlpha)
    MMaps.GUI_Update()
end, "Toggle Minimap Alpha - 0 to 1")

-- profile area

local btn16 = CreateButton(gui, 130, 24, {"BOTTOM", gui, "BOTTOM", 0, 30}, "Copy Profile", function()
    MMaps.CopyProfileFrom()
end, "Copy all settings from another profile")

local btn17 = CreateButton(gui, 130, 24, {"BOTTOM", gui, "BOTTOM", 150, 30}, "Reset Profile", function()
    MMaps.ResetProfileToDefaults()
end, "Reset all settings to default values")

-- --==================================================
-- -- GUI Labels Section
-- --==================================================

local currentProfileLabel
local function CreateCurrentProfileLabel(parent)
    if not currentProfileLabel then
        currentProfileLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        currentProfileLabel:SetPoint("BOTTOMLEFT", 20, 30)
        currentProfileLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    end
    return currentProfileLabel
end

function MMaps.GUI_Update()
    local profile = MMaps.GetProfile()
    if not currentProfileLabel then
        currentProfileLabel = CreateCurrentProfileLabel(gui)
    end
    currentProfileLabel:SetText("Current Profile: \n\n|cff00ff00" .. (profile.name or "Unknown") .. "|r")
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
    btn15:SetText("Alpha: " .. (profile.minimapAlpha and "|cff00ff00" .. profile.minimapAlpha .. "|r" or "|cffff0000OFF|r"))
    if profile.color then
        btn13:SetText("Color: |cff" .. string.format("%02x%02x%02x", profile.color.r * 255, profile.color.g * 255, profile.color.b * 255) .. "RGB|r")
    else
        btn13:SetText("Color: |cffff0000OFF|r")
    end
end

--==================================================
-- Events Section
--==================================================

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
            gui:ClearAllPoints()
            gui:SetPoint("CENTER", 0, 0)
            gui:Show()
            MMaps.GUI_Update()
        end
    end
end)

SLASH_MMAPSGUI1 = "/mmaps"
SlashCmdList["MMAPSGUI"] = function()
    if gui:IsShown() then
        gui:Hide()
    else
        gui:ClearAllPoints()
        gui:SetPoint("CENTER", 0, 0)
        gui:Show()
        MMaps.GUI_Update()
    end
end