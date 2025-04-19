-- --==================================================
-- -- MatrixMaps -- How to modify this addon:
-- -- Add new functions to functions.lua, add defaults
-- -- to profiles.lua, then add GUI elements to gui.lua
-- --==================================================

local ADDON_NAME = "MatrixMaps"

MMaps = CreateFrame("Frame", ADDON_NAME, UIParent)
MMaps:RegisterEvent("VARIABLES_LOADED")
MMaps:RegisterEvent("PLAYER_LOGIN")

-- --==================================================
-- -- tables section
-- --==================================================

MMaps_DB = {}
MMaps_DB.profiles = {}
MMaps.addonInfo = {
    name    = GetAddOnMetadata(ADDON_NAME, "X-name")   or "Unknown",
    version = GetAddOnMetadata(ADDON_NAME, "Version")  or "Unknown",
    url     = GetAddOnMetadata(ADDON_NAME, "X-url")    or "Unknown",
}

-- --==================================================
-- -- generic section
-- --==================================================

local debug = false

function print(msg)
    if type(msg) == "table" then
        local t = {}
        for k, v in pairs(msg) do
            table.insert(t, k .. "=" .. tostring(v))
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6060" .. MMaps.addonInfo.name .. "|r: " .. table.concat(t, "\n"))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6060" .. MMaps.addonInfo.name .. "|r: " .. (msg or "nil"))
    end
end

function MMaps.Debug(msg)
    if debug then
        print("[DEBUG] " .. (msg or "nil"))
        -- print(debugstack(2, 3, 0)) -- Print the call stack for debugging
    end
end

function MMaps.SafeCall(func)
    local success, err = pcall(func)
    if not success then
        MMaps.Debug("Error: " .. err)
    end
end

function MMaps.TrackTime(label, func)
    local start = GetTime()
    func()
    local duration = (GetTime() - start) * 1000  -- ms

    local class
    if duration < 1 then
        class = "FAST"
    elseif duration < 10 then
        class = "MEDIUM"
    else
        class = "SLOW"
    end

    MMaps.Debug("[" .. label .. "] took " .. format("%.2f", duration) .. "ms (" .. class .. ")")
end

-- --==================================================
-- -- init section
-- --==================================================

local function Greeting()
    local unit = UnitName("player")
    if not MMaps_DB.profiles[unit] or MMaps_DB.profiles[unit].greeting == false then return end

    print("Welcome to |cffff6060" .. MMaps.addonInfo.name .. "|r v" .. MMaps.addonInfo.version)
    print("[ |cffff6060Shift-Right-Click|r ] the Minimap")
    print("Report bugs @ |cffff6060" .. MMaps.addonInfo.url .. "|r")
end

MMaps:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        MMaps.Debug("VARIABLES_LOADED fired")

        MMaps.InitProfiles()
        MMaps.executeAllFunctions()

        Greeting()

        MMaps:UnregisterEvent("VARIABLES_LOADED")
    end
end)
