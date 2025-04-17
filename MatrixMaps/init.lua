-- Project: MatrixMaps
-- Add new functions into functions.lua, then add defaults to profiles.lua,
-- call it here in our bootloader and add GUI elements to gui.lua

MMaps = CreateFrame("Frame", "MMaps", UIParent)
MMaps:RegisterEvent("VARIABLES_LOADED")

MMaps_DB = {}

local addonInfo = {
    name = "MatrixMaps",
    version = "1.0",
    stage = "Alpha",
    author = "Guzruul",
    url = "Turtle Forum > Addons > MatrixMaps",
}

function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff6060MatrixMaps:|r " .. (msg or "nil"))
end

function MMaps.FuncLoader()
    MMaps.HideStuff()
    MMaps.UpdateMinimap()
    MMaps.UpdateMovable()
    MMaps.UpdateZoom()
    MMaps.UpdateAutoZoomOut()
    MMaps.UpdateShape()
    MMaps.UpdateBorder()
    MMaps.UpdateGameTimeZoomClose()
    MMaps.UpdateBorderTop()
    MMaps.UpdateRotatingBorder()
    MMaps.UpdateRotatingSpeed()
    MMaps.UpdateRotatingScale()
    MMaps.UpdateTexColour()
    MMaps.UpdateSnowfall()
end

MMaps:SetScript("OnEvent", function()
    print("Loaded -  Open the GUI via:")
    print("[ |cffff6060/ mmaps|r ] or [ |cffff6060Shift-RightClick|r ]")
    print(addonInfo.stage .. " version (V" .. addonInfo.version .. ")")
    print("Report bugs|r @ |cffff6060" .. addonInfo.url .. "|r")

    MMaps.InitProfiles()
    MMaps.FuncLoader()
    MMaps.SetDefaultPosition()
    MMaps:UnregisterEvent("VARIABLES_LOADED")
end)