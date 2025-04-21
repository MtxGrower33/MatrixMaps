-- --==================================================
-- -- functions
-- --==================================================
-- Each feature (like minimap, zoom, etc.) is stored as a
-- command object in MMaps.features with its own "apply" function.
-- When a feature needs to be used, the HandleFeature
-- function acts as the central command processor.
-- HandleFeature looks up the requested feature in the features
-- collection and executes its apply function.
-- The profile system maintains the state/settings for each feature,
-- which gets passed to the apply function.
-- --==================================================

MMaps.Debug("> functions.lua loading...")

_G = getfenv(0)

local MMaps = MMaps

MMaps.features = {
    minimap = {
        apply = function(value)
            if value then
                Minimap:Show()
            else
                Minimap:Hide()
            end
            MMaps.Debug("Minimap: " .. (value and "shown" or "hidden"))
        end
    },

    movable = {
        apply = function(value)
        if value then
            Minimap:SetMovable(true)
            Minimap:RegisterForDrag("LeftButton")
            Minimap:SetScript("OnDragStart", function() Minimap:StartMoving() end)
            Minimap:SetScript("OnDragStop", function()
                Minimap:StopMovingOrSizing()
                local point, _, relativePoint, xOffset, yOffset = Minimap:GetPoint()
                MMaps.GetProfile().position = {
                    point = point,
                    relativePoint = relativePoint,
                    xOffset = xOffset,
                    yOffset = yOffset
                }
            end)
        else
            Minimap:SetMovable(false)
            Minimap:RegisterForDrag()
            Minimap:SetScript("OnDragStart", nil)
            Minimap:SetScript("OnDragStop", nil)
        end

        -- restore saved position if available
        local profile = MMaps.GetProfile()
        if profile.position then
            Minimap:ClearAllPoints()
            Minimap:SetPoint(
                profile.position.point,
                UIParent,
                profile.position.relativePoint,
                profile.position.xOffset,
                profile.position.yOffset
            )
        end

        MMaps.Debug("Minimap movable: " .. (value and "enabled" or "disabled"))
        end
    },

    zoom = {
        apply = function(value)
            Minimap:EnableMouseWheel(value)
            if value then
                Minimap:SetScript("OnMouseWheel", function()
                    local delta = arg1
                    if delta > 0 then
                        MinimapZoomIn:Click()
                    else
                        MinimapZoomOut:Click()
                    end
                end)
            else
                Minimap:SetScript("OnMouseWheel", nil)
            end
            MMaps.Debug("Minimap zoom: " .. (value and "enabled" or "disabled"))
        end
    },

    autoZoomOut = {
        apply = function(value)
            if value then
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
            MMaps.Debug("Auto zoom: " .. (value and "enabled" or "disabled"))
        end
    },

    minimapAlpha = {
        apply = function(value)
            Minimap:SetAlpha(value)
            MMaps.Debug("Minimap alpha set to " .. value)
        end
    },

    minimapScale = {
        apply = function(value)
            local scale = tonumber(value) or 1.0
            if scale < 0.5 then scale = 0.5 end
            if scale > 2.0 then scale = 2.0 end

            Minimap:SetScale(scale)
            MMaps.Debug("Minimap scale set to " .. scale)
        end
    },

    shape = {
        apply = function(value)
            MMaps.shapes = {
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

            if MMaps.shapes[value] then
                Minimap:SetMaskTexture(MMaps.shapes[value])
            else
                Minimap:SetMaskTexture(MMaps.shapes["Round"])
                value = "Round"
            end
            MMaps.Debug("Minimap shape set to " .. value)
        end
    },

    border = {
        apply = function(value)
            if not MMaps.borderFrame then
                MMaps.borderFrame = CreateFrame("Frame", nil, Minimap)
                MMaps.borderFrame:SetPoint("CENTER", Minimap, "CENTER")
                MMaps.borderFrame:SetWidth(155)
                MMaps.borderFrame:SetHeight(155)
                MMaps.borderFrame:SetScale(1.02)

                MMaps.borderTexture = MMaps.borderFrame:CreateTexture(nil, "LOW")
                MMaps.borderTexture:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\border.tga")
                MMaps.borderTexture:SetAllPoints(MMaps.borderFrame)
            end

            if value == "Alternative" then
                MMaps.borderTexture:Show()
            else
                MMaps.borderTexture:Hide()
            end

            MMaps.Debug("Minimap border: " .. (value == "Alternative" and "shown" or "hidden"))
        end
    },

    extraButtons = {
        apply = function(value)
            if value then
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
            MMaps.Debug("Extra buttons: " .. (value and "shown" or "hidden"))
        end
    },

    borderTop = {
        apply = function(value)
            if not MMaps.borderTopFrame then
                MMaps.borderTopFrame = CreateFrame("Frame", nil, Minimap)
                MMaps.borderTopFrame:SetPoint("BOTTOM", Minimap, "TOP", 0, 7)
                MMaps.borderTopFrame:SetWidth(175)
                MMaps.borderTopFrame:SetHeight(64)
                MMaps.borderTopFrame:SetScale(1)

                MMaps.borderTopTexture = MMaps.borderTopFrame:CreateTexture(nil, "BACKGROUND")
                MMaps.borderTopTexture:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\borderTop.tga")
                MMaps.borderTopTexture:SetAllPoints(MMaps.borderTopFrame)
            end

            if value == "Alternative" then
                MMaps.borderTopTexture:Show()
            else
                MMaps.borderTopTexture:Hide()
            end

            MMaps.Debug("Border top: " .. (value == "Alternative" and "shown" or "hidden"))
        end
    },

    rotatingBorder = {
        apply = function(value)
            MMaps.rotatingTextures = {
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

            -- clean up existing rotating frame if it exists
            if MMaps.RotatingFrame then
                MMaps.RotatingFrame:Hide()
                MMaps.RotatingFrame:SetScript("OnUpdate", nil)
                MMaps.RotatingFrame = nil
            end

            -- ff value is "None" or invalid, we just clean up and return
            local setting = MMaps.rotatingTextures[value]
            if not setting then
                MMaps.Debug("Rotating border: disabled")
                return
            end

            -- get profile settings
            local profile = MMaps.GetProfile()
            local speed = profile.speed or 1
            local scale = profile.scale or 1
            local color = profile.color or { r = 1, g = 1, b = 1 }

            -- create new rotating frame
            local frame = CreateFrame("Frame", nil, Minimap)
            frame:SetPoint("CENTER", Minimap, "CENTER")
            frame:SetWidth(155 * scale)
            frame:SetHeight(155 * scale)

            -- create and setup texture
            local tex = frame:CreateTexture(nil, "BACKGROUND")
            tex:SetTexture(setting.path)
            tex:SetAllPoints(frame)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
            tex:SetAlpha(setting.a or 1)
            ---@diagnostic disable-next-line: inject-field
            tex.angle = 0

            frame.texture = tex

            -- rotation update function
            local function OnUpdate()
                ---@diagnostic disable-next-line: inject-field
                tex.angle = (tex.angle or 0) + speed
                ---@diagnostic disable-next-line: inject-field
                if tex.angle > 360 then tex.angle = tex.angle - 360 end
                local s = math.sin(math.rad(tex.angle))
                local c = math.cos(math.rad(tex.angle))
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

            MMaps.Debug("Rotating border: " .. value)
        end
    },

    rotatingSpeed = {
        apply = function(value)
            value = math.min(5, math.max(-5, value))

            -- update profile
            local profile = MMaps.GetProfile()
            profile.speed = value

            -- update existing rotating border if it exists
            if MMaps.RotatingFrame and MMaps.RotatingFrame.texture then
                local tex = MMaps.RotatingFrame.texture

                local function OnUpdate()
                    ---@diagnostic disable-next-line: inject-field
                    tex.angle = (tex.angle or 0) + value
                    ---@diagnostic disable-next-line: inject-field
                    if tex.angle > 360 then tex.angle = tex.angle - 360 end
                    local s = math.sin(math.rad(tex.angle))
                    local c = math.cos(math.rad(tex.angle))
                    tex:SetTexCoord(
                        0.5 - s, 0.5 + c,
                        0.5 + c, 0.5 + s,
                        0.5 - c, 0.5 - s,
                        0.5 + s, 0.5 - c
                    )
                end

                MMaps.RotatingFrame:SetScript("OnUpdate", OnUpdate)
            end

            MMaps.Debug("Rotating speed set to: " .. value)
        end
    },

    rotatingScale = {
        apply = function(value)
            -- ensure value is within bounds (0.1 to 3.0)
            value = math.min(3.0, math.max(0.1, value))

            -- update profile
            local profile = MMaps.GetProfile()
            profile.scale = value

            -- update existing rotating border if it exists
            if MMaps.RotatingFrame then
                MMaps.RotatingFrame:SetWidth(155 * value)
                MMaps.RotatingFrame:SetHeight(155 * value)
            end

            MMaps.Debug("Rotating scale set to: " .. value)
        end
    },

    texColour = {
        apply = function(value)
            value = value or 1

            MMaps.colors = {
                -- basic colors
                { r = 1,   g = 0,   b = 0   },  -- Red
                { r = 1,   g = 0.5, b = 0   },  -- Orange
                { r = 1,   g = 1,   b = 0   },  -- Yellow
                { r = 1,   g = 0.82,b = 0   },  -- Gold
                { r = 0.5, g = 1,   b = 0   },  -- Light Chartreuse
                { r = 0.5, g = 1,   b = 0   },  -- Chartreuse
                { r = 0,   g = 1,   b = 0   },  -- Green
                { r = 0,   g = 1,   b = 0.5 },  -- Spring Green
                { r = 0,   g = 1,   b = 1   },  -- Cyan
                { r = 0,   g = 0.5, b = 1   },  -- Azure
                { r = 0,   g = 0,   b = 1   },  -- Blue
                { r = 0.5, g = 0,   b = 1   },  -- Violet
                { r = 1,   g = 1,   b = 1   },  -- White
                { r = 0.25,g = 0.25,b = 0.25 },  -- Dark Gray

                -- neon metallics
                { r = 1,   g = 0.05, b = 0.05 }, -- Neon Red
                { r = 1,   g = 0.3,  b = 0    }, -- Neon Orange
                { r = 1,   g = 1,    b = 0    }, -- Neon Yellow
                { r = 0.6, g = 1,    b = 0    }, -- Neon Lime
                { r = 0,   g = 1,    b = 0.05 }, -- Neon Green
                { r = 0,   g = 1,    b = 0.5  }, -- Neon Spring Green
                { r = 0,   g = 1,    b = 1    }, -- Neon Cyan
                { r = 0.2, g = 0,    b = 1    }, -- Neon Electric Blue
                { r = 0.7, g = 0,    b = 1    }, -- Neon Violet
                { r = 1,   g = 0,    b = 1    }, -- Neon Magenta

                -- light colors
                { r = 1,   g = 0.7,  b = 0.7  }, -- Light Red
                { r = 1,   g = 0.85, b = 0.7  }, -- Light Orange
                { r = 1,   g = 1,    b = 0.7  }, -- Light Yellow
                { r = 0.85,g = 1,    b = 0.7  }, -- Light Chartreuse
                { r = 0.7, g = 1,    b = 0.7  }, -- Light Green
                { r = 0.7, g = 1,    b = 1    }, -- Light Cyan
                { r = 0.7, g = 0.85, b = 1    }, -- Light Sky Blue
                { r = 0.7, g = 0.7,  b = 1    }, -- Light Blue
                { r = 0.85,g = 0.7,  b = 1    }, -- Light Violet
                { r = 1,   g = 0.7,  b = 1    }, -- Light Magenta

                -- dark colours
                { r = 0.545, g = 0,     b = 0     }, -- Dark Red
                { r = 0.545, g = 0.25,  b = 0     }, -- Dark Orange
                { r = 0.545, g = 0.545, b = 0     }, -- Dark Yellow (Olive)
                { r = 0.25,  g = 0.545, b = 0     }, -- Dark Chartreuse
                { r = 0,     g = 0.545, b = 0     }, -- Dark Green
                { r = 0,     g = 0.545, b = 0.25  }, -- Dark Spring Green
                { r = 0,     g = 0.545, b = 0.545 }, -- Dark Cyan
                { r = 0,     g = 0.25,  b = 0.545 }, -- Dark Blue
                { r = 0.25,  g = 0,     b = 0.545 }, -- Dark Violet
                { r = 0.545, g = 0,     b = 0.545 }, -- Dark Magenta

                -- thx gpt lol
            }

            local profile = MMaps.GetProfile()
            profile.colorIndex = math.floor(tonumber(value))
            ---@diagnostic disable-next-line: deprecated
            if profile.colorIndex > table.getn(MMaps.colors) then
                ---@diagnostic disable-next-line: deprecated
                profile.colorIndex = table.getn(MMaps.colors)
            end
            if profile.colorIndex < 1 then
                profile.colorIndex = 1
            end

            profile.color = MMaps.colors[profile.colorIndex]

            if MMaps.RotatingFrame and profile.color then
                local tex = MMaps.RotatingFrame.texture
                if tex then
                    tex:SetVertexColor(profile.color.r or 1, profile.color.g or 1, profile.color.b or 1)
                end
            end

            MMaps.Debug("Texture color index set to: " .. profile.colorIndex)
        end
    },

    snowfall = {
        apply = function(value)
            if not MMaps.snowfall then
                -- mainframe
                MMaps.snowfall = CreateFrame("Frame", nil, Minimap)
                MMaps.snowfall:SetPoint("CENTER", Minimap, "CENTER", 0, -30)
                MMaps.snowfall:SetWidth(210)
                MMaps.snowfall:SetHeight(250)
                MMaps.flakes = {}
                MMaps.lastSpawnTime = 0
                MMaps.nextSpawnDelay = 0

                -- main function
                function MMaps.CreateSnowflake()
                    local flake = CreateFrame("Frame", nil, MMaps.snowfall)
                    local size = 4 + math.random(0, 4)
                    flake:SetWidth(size)
                    flake:SetHeight(size)

                    local tex = flake:CreateTexture(nil, "ARTWORK")
                    tex:SetTexture("Interface\\AddOns\\MatrixMaps\\img\\snow.tga")
                    tex:SetAllPoints(flake)
                    flake.texture = tex

                    flake.baseX = math.random(0, MMaps.snowfall:GetWidth())
                    flake.x = flake.baseX
                    flake.y = MMaps.snowfall:GetHeight()
                    flake.speed = 10 + math.random(0, 20)

                    flake.wobbleAmplitude = 2 + math.random() * 2
                    flake.wobbleSpeed = 1 + math.random() * 5.5
                    flake.wobbleAngle = math.random() * 6.28

                    flake.spawnTime = GetTime()

                    flake:Show()
                    table.insert(MMaps.flakes, flake)
                end

                -- snowfall update function
                function MMaps.SnowfallOnUpdate()
                    local now = GetTime()

                    -- spawn snowflakes with random interval
                    if now - MMaps.lastSpawnTime > MMaps.nextSpawnDelay then
                        if math.random(0, 100) > 40 then
                            MMaps.CreateSnowflake()
                        end
                        MMaps.lastSpawnTime = now
                        MMaps.nextSpawnDelay = 0.45 + math.random() * 0.15
                    end

                    -- move snowflakes and remove out of bounds
                    local i = 1
                    ---@diagnostic disable-next-line: deprecated
                    while i <= table.getn(MMaps.flakes) do
                        local flake = MMaps.flakes[i]
                        local dt = now - flake.spawnTime
                        flake.spawnTime = now

                        flake.y = flake.y - flake.speed * dt

                        -- wobble effect
                        flake.wobbleAngle = flake.wobbleAngle + flake.wobbleSpeed * dt
                        local wobbleOffset = math.sin(flake.wobbleAngle) * flake.wobbleAmplitude
                        flake.x = flake.baseX + wobbleOffset

                        -- fade snowflakes near the bottom
                        local fadeStart = MMaps.snowfall:GetHeight() * 0.1
                        if flake.y < fadeStart then
                            local alpha = flake.y / fadeStart
                            flake.texture:SetAlpha(alpha)
                        end

                        -- update snowflake position
                        flake:SetPoint("TOPLEFT", MMaps.snowfall, "BOTTOMLEFT", flake.x, flake.y)

                        -- remove snowflakes if they go out of bounds
                        if flake.y < 0 or flake.x < 0 or flake.x > MMaps.snowfall:GetWidth() then
                            flake:Hide()
                            table.remove(MMaps.flakes, i)
                        else
                            i = i + 1
                        end
                    end
                end

                -- FPS limiter
                MMaps.fpsMonitor = CreateFrame("Frame")
                MMaps.fpsMonitor:SetScript("OnUpdate", function()
                    local profile = MMaps.GetProfile()
                    if profile.fpsLimit then
                        if GetFramerate() < 30 and MMaps.snowfall:GetScript("OnUpdate") then
                            MMaps.snowfall:SetScript("OnUpdate", nil)
                        elseif GetFramerate() >= 30 and not MMaps.snowfall:GetScript("OnUpdate") then
                            MMaps.snowfall:SetScript("OnUpdate", MMaps.SnowfallOnUpdate)
                        end
                    end
                end)
            end

            -- toggle snowfall
            local profile = MMaps.GetProfile()
            profile.snowEnabled = value

            if value then
                MMaps.snowfall:Show()
                MMaps.snowfall:SetScript("OnUpdate", MMaps.SnowfallOnUpdate)
            else
                MMaps.snowfall:Hide()
                MMaps.snowfall:SetScript("OnUpdate", nil)
                -- clear existing snowflakes
                for _, flake in ipairs(MMaps.flakes) do
                    flake:Hide()
                end
                MMaps.flakes = {}
            end

            MMaps.Debug("Snowfall: " .. (value and "enabled" or "disabled"))
        end
    },
}

MMaps.misc = {
    HideStuff = function()
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
    end,

    SetDefaultPosition = function()  -- needs rethinking var redundancy
        MMaps.Debug("SetDefaultPosition() called")

        local profile = MMaps.GetProfile()

        if not profile.defaultPositionSet then
            Minimap:ClearAllPoints()
            Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -72)
            Minimap:SetScale(1.0)
            profile.defaultPositionSet = true

            -- save the default position into the profile
            profile.position = { point = "TOPRIGHT", relativePoint = "TOPRIGHT", xOffset = -50, yOffset = -72 }

            print("Initialized default position")
        end
    end,

    ToggleFPSLimit = function()
        MMaps.Debug("ToggleFPSLimit() called")

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
    end,
}

-- --==================================================
-- -- loader section
-- --==================================================

function MMaps.HandleFeature(featureName, toggle)
    local profile = MMaps.GetProfile()

    if toggle ~= nil then
        profile[featureName] = toggle
    end

    if MMaps.features[featureName] then
        MMaps.features[featureName].apply(profile[featureName])
    end
end

function MMaps.InitializeFeatures()
    MMaps.Debug("Initializing features")
    local profile = MMaps.GetProfile()

    MMaps.misc.SetDefaultPosition()
    MMaps.misc.HideStuff()

    MMaps.HandleFeature("minimap", profile.minimap)
    MMaps.HandleFeature("minimapAlpha", profile.minimapAlpha)
    MMaps.HandleFeature("movable", profile.movable)
    MMaps.HandleFeature("zoom", profile.zoom)
    MMaps.HandleFeature("autoZoomOut", profile.autoZoomOut)
    MMaps.HandleFeature("minimapScale", profile.minimapScale)
    MMaps.HandleFeature("shape", profile.shape)
    MMaps.HandleFeature("border", profile.border)
    MMaps.HandleFeature("extraButtons", profile.extraButtons)
    MMaps.HandleFeature("borderTop", profile.borderTop)
    MMaps.HandleFeature("rotatingBorder", profile.rotatingBorder)
    MMaps.HandleFeature("rotatingSpeed", profile.speed)
    MMaps.HandleFeature("rotatingScale", profile.scale)
    MMaps.HandleFeature("texColour", profile.colorIndex)
    MMaps.HandleFeature("snowfall", profile.snowEnabled)
end
