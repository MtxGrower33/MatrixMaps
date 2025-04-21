-- --==================================================
-- -- MatrixMaps
-- --==================================================
-- To add new features:
-- [functions.lua] Add new feature to MMaps.features/misc with an apply function
-- [profiles.lua] Add new feature default value to defaults table if needed
-- [functions.lua] Add new feature to MMaps.Initializers if setup needed
-- [gui.lua] Add elements to CreateUI() if UI controls needed
-- [gui.lua] Add elements to UpdateUI() if UI state updates needed
-- --==================================================

local ADDON_NAME = "MatrixMaps"

MMaps = CreateFrame("Frame", ADDON_NAME, UIParent)
MMaps:RegisterEvent("VARIABLES_LOADED")

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
-- -- debug section
-- --==================================================

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

local debug = false

local debugCount = 0
function MMaps.Debug(msg)
    if debug then
        debugCount = debugCount + 1
        local stack = debugstack(2, 1, 0)
        local start, finish = string.find(stack, "[^\\/:]+%.lua")
        local file = start and string.sub(stack, start, finish) or "unknown"
        print("[DEBUG][ " .. debugCount .. " ][|cff00ff00" .. file .. "|r]: " .. (msg or "nil"))
        -- print(debugstack(2, 3, 0)) -- can be enabled if needed
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
    MMaps.Debug("Greeting fired")
    local unit = UnitName("player")
    if not MMaps_DB.profiles[unit] or MMaps_DB.profiles[unit].greeting == false then return end

    print("Welcome to |cffff6060" .. MMaps.addonInfo.name .. "|r v" .. MMaps.addonInfo.version)
    print("[ |cffff6060Shift-Right-Click|r ] the Minimap")
    print("Report bugs @ |cffff6060" .. MMaps.addonInfo.url .. "|r")
end

MMaps:SetScript("OnEvent", function()
    MMaps.Debug("VARIABLES_LOADED fired")

    MMaps.InitProfiles()
    MMaps.InitializeFeatures()
    MMaps.CreateUI()

    Greeting()

    MMaps:UnregisterEvent("VARIABLES_LOADED")
end)

MMaps.Debug("> init.lua done.")
