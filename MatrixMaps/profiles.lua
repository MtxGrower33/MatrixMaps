-- Profile Manager for the addon

local defaults = {
    defaultPositionSet = false,
    minimap = true,
    movable = false,
    zoom = true,
    autoZoomOut = true,
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
    MMaps_DB.profiles = MMaps_DB.profiles or {}
    if not MMaps_DB.profiles["Default"] then
        local defaultProfile = CopyDefaults()
        defaultProfile.name = "Default"
        MMaps_DB.profiles["Default"] = defaultProfile
    end
    MMaps_DB.current = MMaps_DB.current or "Default"
end
function MMaps.GetProfile()
    return MMaps_DB.profiles[MMaps_DB.current]
end
function MMaps.CreateProfile(name)
    if name and name ~= "" and name ~= "Default" and not MMaps_DB.profiles[name] then
        local newProfile = CopyDefaults()
        newProfile.name = name
        MMaps_DB.profiles[name] = newProfile
    end
end
function MMaps.SwitchProfile(name)
    if MMaps_DB.profiles[name] then
        MMaps_DB.current = name
        MMaps.FuncLoader()
    end
end
function MMaps.DeleteProfile(name)
    if name ~= "Default" and MMaps_DB.profiles[name] then
        MMaps_DB.profiles[name] = nil
        if MMaps_DB.current == name then
            MMaps_DB.current = "Default"
            MMaps.FuncLoader()
        end
    end
end
