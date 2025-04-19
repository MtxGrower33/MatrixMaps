-- --==================================================
-- -- profile manager section
-- --==================================================

local defaults = {
    defaultPositionSet = false,
    greeting = true,
    minimap = true,
    movable = false,
    zoom = true,
    autoZoomOut = true,
    minimapAlpha = 0.8,
    shape = "Round",
    border = "Alternative",
    gametimeZoomClose = false,
    borderTop = "Alternative",
    rotatingBorder = "Aura1",
    speed = -0.2,
    fpsLimit = true,
    scale = 1.7,
    color = { r = 1, g = 0.84, b = 0 },
    snowEnabled = true,
}

local function CopyDefaults()
    local t = {}
    for k, v in pairs(defaults) do
        t[k] = v
    end
    return t
end

function MMaps.InitProfiles()
    local charName = UnitName("player") or "Unknown"

    if not MMaps_DB.profiles[charName] then
        local newProfile = CopyDefaults()
        newProfile.name = charName
        MMaps_DB.profiles[charName] = newProfile
        MMaps.Debug("Created new profile for: " .. charName)
    else
        MMaps.Debug("Loaded existing profile for: " .. charName)
    end

    MMaps_DB.current = charName
end

function MMaps.GetProfile()
    return MMaps_DB.profiles[MMaps_DB.current]
end

function MMaps.ResetProfileToDefaults()
    local profile = MMaps.GetProfile()
    local current = MMaps_DB.current
    if not current or not MMaps_DB.profiles[current] then
        MMaps.Debug("Reset aborted: profile not found for " .. (current or "nil"))
        return
    end

    local resetProfile = CopyDefaults()
    resetProfile.name = current

    if profile.fpsLimit ~= resetProfile.fpsLimit then
        MMaps.Debug("FPS limit differs, showing reload warning")
        StaticPopupDialogs["MMAPS_RESET_PROFILE"] = {
            text = "Reset profile to defaults?\nFPS limit change requires a reload.",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                MMaps_DB.profiles[current] = resetProfile
                MMaps.Debug("Profile reset with reload: " .. current)
                MMaps.executeAllFunctions()
                MMaps.GUI_Update()
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }

        local popup = StaticPopup_Show("MMAPS_RESET_PROFILE")
        if popup then
            popup:SetFrameStrata("TOOLTIP")
            popup:ClearAllPoints()
            popup:SetPoint("TOP", UIParent, "TOP", 0, -50)
        end
    else
        MMaps_DB.profiles[current] = resetProfile
        MMaps.Debug("Profile reset without reload: " .. current)
        MMaps.executeAllFunctions()
        MMaps.GUI_Update()
    end
end

function MMaps.CopyProfileFrom()
    StaticPopupDialogs["MMAPS_COPY_PROFILE"] = {
        text = "Enter character name to copy profile from:",
        button1 = "Copy",
        button2 = "Cancel",
        hasEditBox = 1,
        maxLetters = 10,
        OnAccept = function()
            local popup = getglobal("StaticPopup1EditBox")
            local fromName = popup and popup:GetText() or ""
            local current = MMaps_DB.current

            if fromName ~= "" and MMaps_DB.profiles[fromName] and current then
                local source = MMaps_DB.profiles[fromName]
                local copy = {}

                for k, v in pairs(source) do
                    if k ~= "name" then
                        copy[k] = v
                    end
                end

                copy.name = current
                MMaps_DB.profiles[current] = copy

                MMaps.Debug("Copied profile from " .. fromName .. " to " .. current)
                MMaps.executeAllFunctions()
                MMaps.GUI_Update()
            else
                DEFAULT_CHAT_FRAME:AddMessage("Profile \"" .. fromName .. "\" not found.")
                MMaps.Debug("Copy failed: source profile \"" .. fromName .. "\" not found.")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 1,
    }

    local popup = StaticPopup_Show("MMAPS_COPY_PROFILE")
    if popup then
        local editBox = getglobal("StaticPopup1EditBox")
        if editBox then
            editBox:SetText("")
            editBox:SetAutoFocus(true)
        end
        popup:SetFrameStrata("TOOLTIP")
        popup:ClearAllPoints()
        popup:SetPoint("TOP", UIParent, "TOP", 0, -50)
    end
end

function MMaps.ListProfiles()
    local list = {}
    for name in pairs(MMaps_DB.profiles) do
        MMaps.Debug("Profile: " .. name)
        table.insert(list, name)
    end
    return list
end
































































-- -- Profile Manager for the addon

-- MMaps_DB = {}

-- local defaults = {
--     defaultPositionSet = false,
--     minimap = true,
--     movable = false,
--     zoom = true,
--     autoZoomOut = true,
--     shape = "Round",
--     border = "Alternative",
--     gametimeZoomClose = false,
--     borderTop = "Alternative",
--     rotatingBorder = "Aura1",
--     speed = -0.2,
--     fpsLimit = true,
--     scale = 1.7,
--     color = { r = 1, g = 0.84, b = 0 },
--     snowEnabled = true,
-- }

-- local function CopyDefaults()
--     local t = {}
--     for k, v in pairs(defaults) do
--         t[k] = v
--     end
--     return t
-- end

-- function MMaps.InitProfiles()
--     MMaps_DB.profiles = MMaps_DB.profiles or {}

--     local charName = UnitName("player") or "Unknown"

--     if not MMaps_DB.profiles[charName] then
--         local newProfile = CopyDefaults()
--         newProfile.name = charName
--         MMaps_DB.profiles[charName] = newProfile
--     end

--     MMaps_DB.current = charName
-- end

-- function MMaps.GetProfile()
--     return MMaps_DB.profiles[MMaps_DB.current]
-- end

-- function MMaps.ResetProfileToDefaults()
--     local profile = MMaps.GetProfile()
--     local current = MMaps_DB.current
--     if not current or not MMaps_DB.profiles[current] then return end

--     local resetProfile = CopyDefaults()
--     resetProfile.name = current

--     if profile.fpsLimit ~= resetProfile.fpsLimit then
--         StaticPopupDialogs["MMAPS_RESET_PROFILE"] = {
--             text = "Reset profile to defaults?\nFPS limit change requires a reload.",
--             button1 = "Yes",
--             button2 = "No",
--             OnAccept = function()
--                 MMaps_DB.profiles[current] = resetProfile
--                 MMaps.FuncLoader()
--                 MMaps.GUI_Update()
--                 ReloadUI()
--             end,
--             timeout = 0,
--             whileDead = true,
--             hideOnEscape = true,
--             preferredIndex = 3,
--         }

--         local popup = StaticPopup_Show("MMAPS_RESET_PROFILE")
--         if popup then
--             popup:SetFrameStrata("TOOLTIP")
--             popup:ClearAllPoints()
--             popup:SetPoint("TOP", UIParent, "TOP", 0, -50)
--         end
--     else
--         MMaps_DB.profiles[current] = resetProfile
--         MMaps.FuncLoader()
--         MMaps.GUI_Update()
--     end
-- end

-- function MMaps.CopyProfileFrom()
--     StaticPopupDialogs["MMAPS_COPY_PROFILE"] = {
--         text = "Enter character name to copy profile from:",
--         button1 = "Copy",
--         button2 = "Cancel",
--         hasEditBox = 1,
--         maxLetters = 50,
--         OnAccept = function()
--             local popup = getglobal("StaticPopup1EditBox")
--             local fromName = popup and popup:GetText() or ""
--             local current = MMaps_DB.current

--             if fromName ~= "" and MMaps_DB.profiles[fromName] and current then
--                 local source = MMaps_DB.profiles[fromName]
--                 local copy = {}

--                 for k, v in pairs(source) do
--                     if k ~= "name" then
--                         copy[k] = v
--                     end
--                 end

--                 copy.name = current
--                 MMaps_DB.profiles[current] = copy

--                 MMaps.FuncLoader()
--                 MMaps.GUI_Update()
--             else
--                 DEFAULT_CHAT_FRAME:AddMessage("Profile \"" .. fromName .. "\" not found.")
--             end
--         end,
--         timeout = 0,
--         whileDead = true,
--         hideOnEscape = true,
--         preferredIndex = 1,
--     }

--     local popup = StaticPopup_Show("MMAPS_COPY_PROFILE")
--     if popup then
--         local editBox = getglobal("StaticPopup1EditBox")
--         if editBox then
--             editBox:SetText("")
--             editBox:SetAutoFocus(true)
--         end
--         popup:SetFrameStrata("TOOLTIP")
--         popup:ClearAllPoints()
--         popup:SetPoint("TOP", UIParent, "TOP", 0, -50)
--     end
-- end








-- function MMaps.CreateProfile(name)
--     if name and name ~= "" and name ~= "Default" and not MMaps_DB.profiles[name] then
--         local newProfile = CopyDefaults()
--         newProfile.name = name
--         MMaps_DB.profiles[name] = newProfile
--     end
-- end

-- function MMaps.SwitchProfile(name)
--     if MMaps_DB.profiles[name] then
--         MMaps_DB.current = name
--         MMaps.FuncLoader()
--     end
-- end

-- function MMaps.DeleteProfile(name)
--     if name ~= "Default" and MMaps_DB.profiles[name] then
--         MMaps_DB.profiles[name] = nil
--         if MMaps_DB.current == name then
--             MMaps_DB.current = "Default"
--             MMaps.FuncLoader()
--         end
--     end
-- end
